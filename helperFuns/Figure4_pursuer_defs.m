% Requires
% time_horizon
% relv_states

pursuer1_initial_state = [1;0;1;0];
pursuer2_initial_state = [10;0;10;0];
pursuer3_initial_state = [30;0;1;0];
pursuer_u_limit = 4;

% Pursuer system definitions
sys_DI_1D = getChainOfIntegLtiSystem(2, 0.1, Polyhedron('lb',-1,'ub',1));
pursuer_sys_state_mat = blkdiag(sys_DI_1D.state_mat, sys_DI_1D.state_mat);
pursuer_sys_input_mat = blkdiag(sys_DI_1D.input_mat, sys_DI_1D.input_mat);
pursuer_input_space = Polyhedron('lb',-[1;1],'ub',[1;1]);
pursuer_sys = LtiSystem('StateMatrix', pursuer_sys_state_mat, ...
                        'InputMatrix', pursuer_sys_input_mat, ...
                        'InputSpace', pursuer_input_space);

% Obtain the pursuer reach set with zero state and unit input                        
Figure4_pursuer_unit_input_position_set

% Compute the zero input (natural dynamics) of the pursuers
pursuer_position_set_1_zero_input = zeros(2,time_horizon);
pursuer_position_set_2_zero_input = zeros(2,time_horizon);
pursuer_position_set_3_zero_input = zeros(2,time_horizon);
for t_indx=1:time_horizon
    pursuer_position_set_1_zero_input(:, t_indx) = ...
        pursuer_Z(4*(t_indx-1) + relv_states,:) * pursuer1_initial_state;
    pursuer_position_set_2_zero_input(:, t_indx) = ...
        pursuer_Z(4*(t_indx-1) + relv_states,:) * pursuer2_initial_state;
    pursuer_position_set_3_zero_input(:, t_indx) = ...
        pursuer_Z(4*(t_indx-1) + relv_states,:) * pursuer3_initial_state;
end

% Plot the forward position sets for the pursuers
pursuer_team_position_set_zero_input = [
    pursuer1_initial_state(relv_states,1), pursuer_position_set_1_zero_input;
    pursuer2_initial_state(relv_states,1), pursuer_position_set_2_zero_input;
    pursuer3_initial_state(relv_states,1), pursuer_position_set_3_zero_input];
for pursuer_indx = 1:3
    pursuer_position_set_zero_input = ...
        pursuer_team_position_set_zero_input(...
            2*(pursuer_indx-1)+1 : 2*(pursuer_indx-1)+2, :);
    for t_indx = 2:plot_t_skip:time_horizon+1
        fprintf('Plotting time for pursuer %d: %d\n', pursuer_indx, t_indx-1);
        plot(pursuer_position_set_zero_input(:, t_indx) + ...
            pursuer_u_limit * ...
                pursuer_position_sets_zero_state_unit_input(t_indx), ...
            'alpha', 0);
        drawnow
    end
end