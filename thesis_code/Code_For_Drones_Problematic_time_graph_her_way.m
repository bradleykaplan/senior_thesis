clear all
AverageEmpty=[];
AverageFull=[];
TimeAverageEmpty=[];
TimeAverageFull=[];
step = .01;
totalinstance=50;
for instance=1:totalinstance
    instance
    Nstations=2;
    Ncars=2;
    Nspots=2;
    
    Occupied_Spaces=zeros(Nstations,Nspots);
    Reserved_Spaces=Occupied_Spaces;%zeros(Nstations,Nspots);
    
    %Occupied_Spaces(1,1:Nspots)=1;%initalcondition, spots 1 and 2 are taken
    %Occupied_Spaces(2,1:Nspots)=1;%initalcondition, spots 1 and 2 are taken
    Occupied_Spaces(1:Ncars)=1;
    
    Occupied_Spaces_vect=Occupied_Spaces;
    Reserved_Spaces_vect=Reserved_Spaces;
    time_vect=[0];
    
    
    lambda=1;%graph doesn't give expected results, probably due to issue with lambda (because increase in mu gives greater P1)
    mu=1;
    
    Tfinal=30;%actual time
    t=0;
    
    while t<Tfinal
        TimeNextCustomer=exprnd(1/lambda,Nstations,1).*(sum(Occupied_Spaces+Reserved_Spaces,2)<Nspots);%take Nstations exponential random variables, sum says if have at least 1 car at station
        TimeNextReturn=exprnd(1/mu,Nstations,Nspots).*Reserved_Spaces;
        TimeToPark=.5;
        TimeFromPark=.5;
        
        TimeNextCustomer(TimeNextCustomer==0)=Inf;
        TimeNextReturn(TimeNextReturn==0)=Inf;
        
        if min(TimeNextCustomer(:))<min(TimeNextReturn(:)) % Next event is an arrival
            [time,station]=min(TimeNextCustomer(:));
            %origin=station;
            available_stations=setdiff(1:Nstations,station);
            Destination=available_stations(randi(numel(available_stations)));
            if (Destination==station) || (sum(Occupied_Spaces(Destination,:)+Reserved_Spaces(Destination,:))<Nspots)%Occupied spaces+resurved spaces less than Nspots
                t=t+time;
                
                Free_Spots=((1-Occupied_Spaces(Destination,:)).*(1-Reserved_Spaces(Destination,:)));
                Free_Spots=find(Free_Spots);
                Spot_Reserved=Free_Spots(randi(length(Free_Spots)));
                Reserved_Spaces(Destination,Spot_Reserved)=1;
                
                Free_Spots_origin=((1-Occupied_Spaces(station,:)).*(1-Reserved_Spaces(station,:)));
                Free_Spots_origin=find(Free_Spots_origin);
                Car_Taken=Free_Spots_origin(randi(length(Free_Spots_origin)));
                Reserved_Spaces(station,Car_Taken)=1;
                
                if t>=Tfinal
            break
        else
            time_vect(end+1)=t;
            Occupied_Spaces_vect(:,:,end+1)=Occupied_Spaces;
            Reserved_Spaces_vect(:,:,end+1)=Reserved_Spaces;
        end
            
                t=t+TimeFromPark;
                Occupied_Spaces(station,Car_Taken)=1;%retrieved car from parking lot
                Reserved_Spaces(station,Car_Taken)=0;
                
                %Occupied_Spots=find(Occupied_Spaces(station,:));
                %Car_Taken=Occupied_Spots(randi(length(Occupied_Spots)));
                Occupied_Spaces(station,Car_Taken)=0;
                
                if t>=Tfinal
            break
        else
            time_vect(end+1)=t;
            Occupied_Spaces_vect(:,:,end+1)=Occupied_Spaces;
            Reserved_Spaces_vect(:,:,end+1)=Reserved_Spaces;
        end
                
            end
        else
            [Station_Returned,Spot_Returned]=find(TimeNextReturn==min(min(TimeNextReturn)));
            Occupied_Spaces(Station_Returned,Spot_Returned)=1;
            Reserved_Spaces(Station_Returned,Spot_Returned)=0;
            t=t+min(TimeNextReturn(:));
            
            if t>=Tfinal
            break
        else
            time_vect(end+1)=t;
            Occupied_Spaces_vect(:,:,end+1)=Occupied_Spaces;
            Reserved_Spaces_vect(:,:,end+1)=Reserved_Spaces;
        end
            
            t=t+TimeToPark;
            Occupied_Spaces(Station_Returned,Spot_Returned)=0;%went to parking lot, want spot to be occupied but don't want drone available
            
            if t>=Tfinal
            break
        else
            time_vect(end+1)=t;
            Occupied_Spaces_vect(:,:,end+1)=Occupied_Spaces;
            Reserved_Spaces_vect(:,:,end+1)=Reserved_Spaces;
        end
            
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
    NumStationsProbavg=getProbStationsavg(NumCarsPerStationOccupied,NumCarsPerStationReserved,Nspots,time_vect,Tfinal,totalinstance,step,Nstations);
    dimension8=size(NumStationsProbavg);
    for i=1:dimension8(2)
        NumStationsProbavgi(instance,i)=NumStationsProbavg(1,i);
    end
    %NumCarsFullavgSee=getNumCarsPerStationFullavg(NumCarsFullavg);
end
dimension9=size(NumStationsProbavgi);
for i=1:dimension9(2)
    sumsNumStationsProbavgi(i)=sum(NumStationsProbavgi(1:dimension9(1),i));
end
timearray=1:dimension9(2);
genXYPlot(timearray,sumsNumStationsProbavgi,'plot',Tfinal,step)

figure;plot(sumsNumStationsProbavgi,'o-');xlim([0,Tfinal/step])

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
    %alreadycounted=0;
    for j=1:dimension2(1)
        %if alreadycounted==0
            if NumCarsPerStationOccupied(j,i)==0
                TimeEmptyStations = TimeEmptyStations+time_vect(i+1)-time_vect(i);
                %alreadycounted=1;
            end
        %end
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


function ProbStationsavg = getProbStationsavg(NumCarsPerStationOccupied,NumCarsPerStationReserved,Nspots,time_vect,Tfinal,totalinstance,step,Nstations)
dimension2 = size(NumCarsPerStationOccupied);
ProbStationsavg=zeros(1,ceil((Tfinal+1)/step));
time_vect2=time_vect;
time_vect2(end+1)=Tfinal;
for i = 1:dimension2(2)
    for j=1:dimension2(1)
            if NumCarsPerStationOccupied(j,i)+NumCarsPerStationReserved(j,i)==Nspots
                t_on=min(floor((Tfinal)/step),max(1,floor(time_vect2(i)/step)));%is the min statement valid???
                t_off=min(floor((Tfinal+1)/step),max(t_on+1,floor(time_vect2(i+1)/step)));
                %if t_off>410
                    %t_on
                    %t_off
                %end
                ProbStationsavg(1,t_on:t_off)=ProbStationsavg(1,t_on:t_off) + (1/(totalinstance*Nstations));
                %alreadycounted=1;
            %elseif NumCarsPerStationOccupied(j,i)==0
                %t_on=min(floor((Tfinal)/step),max(1,floor(time_vect2(i)/step)));%is the min statement valid???
                %t_off=min(floor((Tfinal+1)/step),max(t_on+1,floor(time_vect2(i+1)/step)));
                %if t_off>410
                    %t_on
                    %t_off
                %end
                %ProbStationsavg(1,t_on:t_off)=ProbStationsavg(1,t_on:t_off) + (1/(totalinstance*Nstations));
                %alreadycounted=1;
            end
        end
        %end
    end
end

function FullStationsavg = getFullStationsavg(NumCarsPerStationOccupied,Nspots,time_vect,Tfinal,totalinstance,step)
dimension2 = size(NumCarsPerStationOccupied);
%FullStationsavg = 0;
%time_vect(end+1)=Tfinal;
FullStationsavg=zeros(1,round((Tfinal+1)/step));
for i = 1:dimension2(2)
    %alreadycounted=0;
    for j=1:dimension2(1)
        %if alreadycounted==0
        for k=1:(round((Tfinal+1)/step))
            if i==dimension2(2)
                toff=Tfinal;
            else
                toff=time_vect(i+1);
            end
            if NumCarsPerStationOccupied(j,i)==Nspots %&& k<(time_vect(i)/step) && k<toff/step %(time_vect(i)/step)<=(k+(1))%squeezes or stretches according to step, so k+1/step also stretches and squeezes 
                FullStationsavg(1,k) = 1/totalinstance;
                %alreadycounted=1;
            end
        end
        %end
    end
end
end
%function numCarsPerStationFullavg = getNumCarsPerStationFullavg(NumCarsFullavg)
%dimension4 = size(NumCarsFullavg);
%numPages2 = dimension4(2);
%numCarsPerStationFullavg=zeros(1,numPages2);
%for i = 1:numPages2
    %numCarsPerStationFullavg(i)=sum(NumCarsFullavg(1,i));
%end
%end
function genXYPlot(X,Y,titleName,Tfinal,step)
 
   
    %create the figure, commented out for random error
    figure('Name',titleName);
    
    %plot the voltages with respect to time
    plot(X,Y);
    
    %label plot
    xlabel('time');
    ylabel('Is station full? (1=yes)');
    space={' '};
    title(strcat('Percentage of full stations per time, moving average',space,titleName));
    
    xlim([-0.1,((Tfinal+1)/step)+0.1])
   
end

%Want to say something like 'if 2 cars at one station and 0 cars at other
%and no spaces reserved, then add 1 for each and then divide by time'