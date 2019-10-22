elapsed_time_solver = elapsed_time_fmincon;
pursuer_color_list=['g','b','k','m','c','r'];

% Decode the feas_list into indexed time stamps
enum_feas_list = [feas_list, (1:count_feas)'];

pursuer_compute_time_cvx = zeros(time_horizon+1,1);
pursuer_compute_time_solver = zeros(time_horizon+1,1);
prob_capture_val_matrix = zeros(time_horizon+1,6);
prob_capture_arg_indx_matrix = nan(3, time_horizon+1);

for pursuer_indx = 1:3
    pursuer_indx_match = enum_feas_list(:,1) == pursuer_indx;
    time_and_indx = [enum_feas_list(pursuer_indx_match,2), ...
                     enum_feas_list(pursuer_indx_match,4)];
    unique_time_steps = unique(time_and_indx(:,1))';
    for t_indx_plus1 = unique_time_steps
        indices_to_use = time_and_indx(time_and_indx(:,1) == t_indx_plus1,2);
        
        % Pursuer cvx time
        pursuer_compute_time_cvx(t_indx_plus1) = ...
            pursuer_compute_time_cvx(t_indx_plus1) + ...
            sum(elapsed_time_cvx(indices_to_use));

        % Pursuer solver time
        pursuer_compute_time_solver(t_indx_plus1) = ...
            pursuer_compute_time_solver(t_indx_plus1) + ...
            sum(elapsed_time_solver(indices_to_use));
        
        % Initial guess
        prob_capture_val_matrix(t_indx_plus1, 2*(pursuer_indx-1)+1) = ...
            max(init_feas_prob_catch_value(indices_to_use));
        
        % Prob capture
        [prob_capture_val_matrix(t_indx_plus1, 2*(pursuer_indx-1)+2), ...
                prob_capture_arg_indx_matrix(pursuer_indx, t_indx_plus1)] = ...
            max(max_feas_prob_catch_value(indices_to_use));
        
        
        % Show the indices being considered
        if length(indices_to_use) > 1
            fprintf('Pursuer %d | Multiple indices (%d) at t=%d | %s \n', ...
                pursuer_indx, length(indices_to_use), t_indx_plus1-1, ...
                num2str(indices_to_use'));                        
        else
            fprintf('Pursuer %d | Single index at t=%d         | %d \n', ...
                pursuer_indx, t_indx_plus1-1, indices_to_use);
        end        
    end
end


%% Plot stem plot of computational time
figure(2);
clf;
hold on;
computeTime_markerSize = 20;
computeTime_linewidth = 3;
% stem(0:time_horizon, elapsed_time_pursuer_reach, ...
%     'DisplayName', 'Pursuer reach set');
% stem(0:time_horizon, elapsed_time_target_support, ...
%     'DisplayName', 'Target support');
% stem(0:time_horizon, elapsed_time_feas_poly, ...
%     'DisplayName', 'Feasibility check');
stem(0:time_horizon, elapsed_time_feas_poly + elapsed_time_pursuer_reach + ...
    elapsed_time_target_support, 'ms', 'filled', ...
    'MarkerSize', computeTime_markerSize, 'LineWidth', computeTime_linewidth,...
    'DisplayName', 'Feasibility');
stem(0:time_horizon, pursuer_compute_time_cvx, 'bo', 'filled', ...
    'MarkerSize', computeTime_markerSize, 'LineWidth', computeTime_linewidth,...
    'DisplayName', 'Initial guess');
stem(0:time_horizon, pursuer_compute_time_solver, 'rv', 'filled', ...
    'MarkerSize', computeTime_markerSize, 'LineWidth', computeTime_linewidth,...
    'DisplayName', 'Optimization');
total_time = elapsed_time_feas_poly + elapsed_time_pursuer_reach + ...
    elapsed_time_target_support + pursuer_compute_time_cvx + ...
    pursuer_compute_time_solver;
stem(0:time_horizon, total_time, 'kp', 'filled',  ...
    'MarkerSize', computeTime_markerSize, 'LineWidth', computeTime_linewidth,...
    'DisplayName', 'Total time');
% h = plot(0:time_horizon, 10 *ones(time_horizon+1,1), 'k--');
% h.Annotation.LegendInformation.IconDisplayStyle = 'off';
% h = plot(0:time_horizon, 60 *ones(time_horizon+1,1), 'k--');
% h.Annotation.LegendInformation.IconDisplayStyle = 'off';
% dim = [0.35 0.71 0.09 0.06];
% t=annotation('textbox',dim,'String','1 min.','FitBoxToText','on', ...
%     'FontSize',fontSize*1.5,'EdgeColor','w');
ax = gca;
ax.YScale = 'log';
ax.YLim = [1e-2, 60];
ax.YTick= [1e-2, 1e-1, 1, 10, 60];
ytickformat('%3.2f');
max_time_minus_fmincon = max(total_time - pursuer_compute_time_solver);
set(gca,'FontSize', fontSize*1.5);
leg = legend('Location','South','NumColumns',4);
grid on;
box on;
xlabel('Time ($\tau$)','Interpreter','latex');
ylabel('Computation time (s)','Interpreter','latex');
set(ax,'Position',[0.1471 0.1838 0.8224 0.5762])

%% Plot reach probability as a side-by-side plot
t_min = min(feas_list(:,2))-1;
% reach_probs_to_plot = 2:2:6;
reach_probs_to_plot = 1:6;
figure(3)
clf
hold on
h=bar(0:time_horizon, prob_capture_val_matrix(:,reach_probs_to_plot),'grouped');
for indx=reach_probs_to_plot
%     set(h(i/2),'FaceColor',pursuer_color_list(i));
    set(h(indx),'FaceColor',pursuer_color_list(indx));
end
axis([0 time_horizon+1 0 1.1])
ax=gca();
ax.XLim =[t_min,time_horizon];
ax.XTick=t_min:2:time_horizon;
ax.YLim =[0,1];
ax.YTick=0:0.2:1;
ax.GridAlpha=0.5;
ax.FontSize=fontSize*1.5;
xlabel('Time ($\tau$)','Interpreter','latex');
ylabel('$\phi_{x}(\bar{z}_{\tau,i},\tau)$','Interpreter','latex');
leg = legend('Patrol robot 1 (Initial guess)','Patrol robot 1 (Optimization)', ...
             'Patrol robot 2 (Initial guess)','Patrol robot 2 (Optimization)', ...
             'Patrol robot 3 (Initial guess)','Patrol robot 3 (Optimization)');
set(leg,'Position', [0.2638 0.1953 0.3769 0.4324],'NumColumns', 1);
% leg = legend('Patrol robot 1', ...
%              'Patrol robot 2', ...
%              'Patrol robot 3');
% set(leg,'location','best','NumColumns', 3);
set(ax, 'Position', [0.1091 0.1849 0.8645 0.4518])
% title('Optimal probability of capture for each pursuer');
grid on
box on