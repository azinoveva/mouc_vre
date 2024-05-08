function system = rcuc_init(thermal,hydro,version)
%% Extract system data from the RCUC dataset

filename = ['RCUC/HT-Ramp/', num2str(thermal), '_', num2str(hydro), ... 
            '_',num2str(version), '_w.mod'];

file = fopen(filename, 'r');

system = struct();

% Read the data linewise
while ~feof(file)
    line = fgetl(file);
    
    % Skip empty lines
    if isempty(line)
        continue;
    end
    
    % If line is not empty, split it into tokens
    tokens = strsplit(line);

    switch tokens{1}
        case 'HorizonLen'
            system.HorizonLen = str2num(tokens{2});
        case 'NumThermal'
            system.NumThermal = str2num(tokens{2});
        case 'NumHydro'
            system.NumHydro = str2num(tokens{2});
        case 'Loads'
            load_values = strsplit(fgetl(file));
            system.Loads = load_values(1:end-1);
        case 'ThermalSection'
            % extract thermal data
            thermal_data = ["Index", "QuadCoef", "LinCoef", ...
                                   "ConstCoef", "MinPower", "MaxPower", ...
                                   "InitStatus", "MinUp", "MinDown", ...
                                   "ColdStartCost", "HotStartCost", "tau", "tauMax", ...
                                   "fixedCost", "SUCC", "InitProduction"];
            for index = 1:system.NumThermal*2
                values = strsplit(fgetl(file));
                if ~ismember(values, 'RampConstraints')
                    thermal_data = [thermal_data; values];    
                end
            end
            % store thermal data
            system.Thermal = thermal_data;
        case 'HydroSection'
            % extract hydro data
            hydro_data = ["Index", "volToPower", "b_h", "maxUsage", ...
                "maxSpillage", "initFlood", "minFlood", "maxFlood"];
            water_flow = [];
            for index = 1:system.NumHydro
                % parameters of a hydro unit
                hydro_values = strsplit(fgetl(file));
                hydro_data = [hydro_data; hydro_values];
                % flow of water through the basin
                flow_values = strsplit(fgetl(file));
                water_flow = [water_flow; flow_values(2:end-1)];
            end
            % Store hydro data
            system.Hydro.Generators = hydro_data;
            system.Hydro.Flow = water_flow;
        otherwise
            % Ignore unrecognized lines
            continue;
    end
end

% Close the file
fclose(file);

end

