function write_kml(lat, lon, alt, filename)
    % Function to write the trajectory and burst point to a KML file.
    % Inputs:
    %   lat      - Latitude values (array)
    %   lon      - Longitude values (array)
    %   alt      - Altitude values (array)
    %   filename - Name of the output KML file (string)
    
    % Open file to write
    fileID = fopen(filename, 'w');
    
    % Write KML header
    fprintf(fileID, '<?xml version="1.0" encoding="UTF-8"?>\n');
    fprintf(fileID, '<kml xmlns="http://www.opengis.net/kml/2.2">\n');
    fprintf(fileID, '<Document>\n');
    fprintf(fileID, '<name>Balloon Trajectory</name>\n');
    fprintf(fileID, '<Placemark>\n');
    fprintf(fileID, '<name>Flight Path</name>\n');
    fprintf(fileID, '<LineString>\n');
    fprintf(fileID, '<tessellate>1</tessellate>\n');
    fprintf(fileID, '<coordinates>\n');
    
    % Write coordinates: longitude,latitude,altitude
    for i = 1:length(lat)
        fprintf(fileID, '%.8f,%.8f,%.2f\n', lon(i), lat(i), alt(i));
    end
    
    % Close LineString tag for the path
    fprintf(fileID, '</coordinates>\n');
    fprintf(fileID, '</LineString>\n');
    fprintf(fileID, '</Placemark>\n');
    
    % Add a Placemark for the Burst Location (last point)
    fprintf(fileID, '<Placemark>\n');
    fprintf(fileID, '<name>RK4 Burst!</name>\n');
    fprintf(fileID, '<Point>\n');
    fprintf(fileID, '<coordinates>%.8f,%.8f,%.2f</coordinates>\n', lon(end), lat(end), alt(end));
    fprintf(fileID, '</Point>\n');
    fprintf(fileID, '</Placemark>\n');
    
    % Close document and KML tags
    fprintf(fileID, '</Document>\n');
    fprintf(fileID, '</kml>');
    
    % Close the file
    fclose(fileID);
end
