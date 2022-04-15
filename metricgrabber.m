% metric grabber

function Metrics = metricgrabber(METDIR, metlast)

met_numbers = 1:metlast;
Metrics = cell(2,1,metlast);

for metnum=1:metlast
    numpadded = sprintf('%04d',metnum);
    FILENAME="metrics"+numpadded+".txt";
    FILEPATH=METDIR+FILENAME;

    metfile = readlines(FILEPATH);


end

end

