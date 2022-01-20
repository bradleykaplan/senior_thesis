clear all
AverageEmpty=[];
AverageFull=[];
TimeAverageEmpty=[];
TimeAverageFull=[];
meansTimeAverageFull=[];
for mu=0.1:0.1:20
    mu
for instance=1:20
    Nstations=2;
    Ncars=2;
    Nspots=2;
    
    Occupied_Spaces=zeros(Nstations,Nspots);
    Reserved_Spaces=zeros(Nstations,Nspots);
    
    %Occupied_Spaces(1,1:Nspots)=1;%initalcondition, spots 1 and 2 are taken
    %Occupied_Spaces(2,1:Nspots)=1;%initalcondition, spots 1 and 2 are taken
    Occupied_Spaces(1:Ncars)=1;
    
    Occupied_Spaces_vect=Occupied_Spaces;
    Reserved_Spaces_vect=Reserved_Spaces;
    time_vect=[0];
    
    
    lambda=1;
    %mu=1;
    
    Tfinal=100;%actual time
    t=0;
    
    while t<Tfinal
        TimeNextCustomer=exprnd(1/lambda,Nstations,1).*(sum(Occupied_Spaces,2)>0);%take Nstations exponential random variables, sum says if have at least 1 car at station
        TimeNextReturn=exprnd(1/mu,Nstations,Nspots).*Reserved_Spaces;
        
        TimeNextCustomer(TimeNextCustomer==0)=Inf;
        TimeNextReturn(TimeNextReturn==0)=Inf;
        
        if min(TimeNextCustomer(:))<min(TimeNextReturn(:)) % Next event is an arrival
            [time,station]=min(TimeNextCustomer(:));
            
            available_stations=setdiff(1:Nstations,station);
            Destination=available_stations(randi(numel(available_stations)));
            
            if (Destination==station) || (sum(Occupied_Spaces(Destination,:)+Reserved_Spaces(Destination,:))<Nspots)%Occupied spaces+resurved spaces less than Nspots
                t=t+time;
                Occupied_Spots=find(Occupied_Spaces(station,:));
                Car_Taken=Occupied_Spots(randi(length(Occupied_Spots)));
                Occupied_Spaces(station,Car_Taken)=0;
                
                Free_Spots=((1-Occupied_Spaces(Destination,:)).*(1-Reserved_Spaces(Destination,:)));
                Free_Spots=find(Free_Spots);
                Spot_Reserved=Free_Spots(randi(length(Free_Spots)));
                Reserved_Spaces(Destination,Spot_Reserved)=1;
                
            end
        else
            [Station_Returned,Spot_Returned]=find(TimeNextReturn==min(min(TimeNextReturn))); % This is wrong - giving a vector, want to know at which station car is returned, should have 2 times at most for car returning
            Occupied_Spaces(Station_Returned,Spot_Returned)=1;
            Reserved_Spaces(Station_Returned,Spot_Returned)=0;
            t=t+min(TimeNextReturn(:));
        end
        if t>=Tfinal
            break
        else
            time_vect(end+1)=t;
            Occupied_Spaces_vect(:,:,end+1)=Occupied_Spaces;
            Reserved_Spaces_vect(:,:,end+1)=Reserved_Spaces;
        end
    end
    
    %figure;plot(squeeze(sum(sum(Occupied_Spaces_vect))))
    %title('total number of occupied spaces')
    %figure;plot(squeeze(sum(sum(Reserved_Spaces_vect))))
    %title('total number of reserved spaces')
    %%
    %figure;plot(squeeze(Occupied_Spaces_vect(1,1,:)))
    %title('Is spot 1 in station 1 occupied?')
    
    %ylim([-0.1,1.1])
    
    %figure;plot(squeeze(sum(Occupied_Spaces_vect,[1,2])+sum(Reserved_Spaces_vect,[1,2])))
    %title('total number of cars')
    
    %figure;imagesc(squeeze(sum(Occupied_Spaces_vect,2)))
    %colorbar
    %title('how many cars are at each station?')
    
    %figure;imagesc(squeeze(sum(Reserved_Spaces_vect,2)))
    %colorbar
    %title('how many cars are traveling to station?')
    
    NumCarsPerStationOccupied=getNumCarsPerStation(Occupied_Spaces_vect);
    NumCarsPerStationReserved=getNumCarsPerStation(Reserved_Spaces_vect);
    NumFullStations=getNumFullStations(NumCarsPerStationOccupied,Nspots);
    dimension3 = size(NumCarsPerStationOccupied);
    AverageFull(instance)=NumFullStations/dimension3(2);
    NumEmptyStations=getNumEmptyStations(NumCarsPerStationOccupied);
    AverageEmpty(instance)=NumEmptyStations/dimension3(2);
    TimeEmptyStations=getTimeEmptyStations(NumCarsPerStationOccupied,time_vect,Tfinal);
    TimeAverageEmpty(instance)=TimeEmptyStations/Tfinal;
    TimeFullStations=getTimeFullStations(NumCarsPerStationOccupied,Nspots,time_vect,Tfinal);
    TimeAverageFull(instance)=TimeFullStations/Tfinal;
end
meansTimeAverageFull(round(mu*10))=mean(TimeAverageFull);
musarray(round(mu*10))=mu;
end
genXYPlot(musarray,meansTimeAverageFull,'plot')

function numCarsPerStation = getNumCarsPerStation(OccupiedSpaces)
% gets a 2d matrix of number of cars per station, every column is
% the number of cars from the page, every row is a station
% so numCarsPerStation(2,3) is the number of cars for page 3 station 2
%numPages will be the number of pages in the 3d array
dimension = size(OccupiedSpaces);
% the number of stations is the number of rows in OccupiedSpaces
numStations= dimension(1);
% the number of pages is the number of Pages in Occupied Spaces
numPages = dimension(3);
% make a numStations by numPages array to insert the number of cars to
numCarsPerStation = zeros(numStations,numPages);
%loop through every page
for i = 1:numPages
    % save the page
    page=OccupiedSpaces(:,:,i);
    %sum the number of cars in each station, or num 1s in each row
    for j=1:numStations
        numCarsPerStation(j,i)=sum(page(j,:)==1);
    end
end
end

function NumFullStations = getNumFullStations(NumCarsPerStationOccupied,Nspots)
dimension2 = size(NumCarsPerStationOccupied);
NumFullStations = 0;
for i = 1:dimension2(2)
    for j=1:dimension2(1)
        if NumCarsPerStationOccupied(j,i)==Nspots
            NumFullStations = NumFullStations + 1;
        end
    end
end
end
function NumEmptyStations = getNumEmptyStations(NumCarsPerStationOccupied)
dimension2 = size(NumCarsPerStationOccupied);
NumEmptyStations = 0;
for i = 1:dimension2(2)
    for j=1:dimension2(1)
        if NumCarsPerStationOccupied(j,i)==0
            NumEmptyStations = NumEmptyStations + 1;
        end
    end
end
end
function TimeEmptyStations = getTimeEmptyStations(NumCarsPerStationOccupied,time_vect,Tfinal)
dimension2 = size(NumCarsPerStationOccupied);
TimeEmptyStations = 0;
time_vect(end+1)=Tfinal;
for i = 1:dimension2(2)
    alreadycounted=0;
    for j=1:dimension2(1)
        if alreadycounted==0
            if NumCarsPerStationOccupied(j,i)==0
                TimeEmptyStations = TimeEmptyStations+time_vect(i+1)-time_vect(i);
                alreadycounted=1;
            end
        end
    end
end
end
function TimeFullStations = getTimeFullStations(NumCarsPerStationOccupied,Nspots,time_vect,Tfinal)
dimension2 = size(NumCarsPerStationOccupied);
TimeFullStations = 0;
time_vect(end+1)=Tfinal;
for i = 1:dimension2(2)
    %alreadycounted=0;
    for j=1:dimension2(1)
        %if alreadycounted==0
            if NumCarsPerStationOccupied(j,i)==Nspots
                TimeFullStations = TimeFullStations+time_vect(i+1)-time_vect(i);
                %alreadycounted=1;
            end
        %end
    end
end
end
function genXYPlot(X,Y,titleName)
 
   
    %create the figure, commented out for random error
    figure('Name',titleName);
    
    %plot the voltages with respect to time
    plot(X,Y);
    
    %label plot
    xlabel('mu/lambda=1');
    ylabel('P1 steady state');
    space={' '};
    title(strcat('P1 steady state vs r',space,titleName));
   
end

%Want to say something like 'if 2 cars at one station and 0 cars at other
%and no spaces reserved, then add 1 for each and then divide by time'