#all arena tracking files must be in the same folder (trackdir) and be named:
#[Arena or Room]Track_[mouse#]_[trialtype]_[experiment]_[Arena or Room].dat
#eg ArenaTrack_102_T01_KH_EJ_PV-SST_Arena.dat

import os
import re
import csv
import math
import numpy

#MUST BE SET EVERY TIME
trackdir = 'E:\LFP Data\CRCNS\Cohort 2\APA'
outputfile = 'Metrics pulled by Python.csv'

    
class Bout:
    def __init__(self, escape, avoid, dist_to_shock, dist_to_shock_ang, dist_travelled, dist_travelled_ang,
                delta_dist_to_shock, delta_dist_to_shock_ang, bout_length, time_since_last_bout): 
        self.escape = escape #0 or 1
        self.avoid = avoid #0 or 1
        self.dist_to_shock = dist_to_shock
        self.dist_to_shock_ang = dist_to_shock_ang
        self.dist_travelled =  dist_travelled
        self.dist_travelled_ang =  dist_travelled_ang
        self.delta_dist_to_shock = delta_dist_to_shock
        self.delta_dist_to_shock_ang = delta_dist_to_shock_ang
        self.bout_length = bout_length #sec
        self.time_since_last_bout = time_since_last_bout #sec

def read_tracking(filename, tracktype='arena'):
    data_list = list()
    # columns: FrameCount 1msTimeStamp RoomX RoomY Sectors State CurrentLevel MotorState Flags FrameInfo
    with open(filename, 'rU') as f:
            reader = csv.reader(f, delimiter='\t')
            for row in reader:
                    if '%%END_HEADER' in row: #move pointer to start of data
                        break
            for row in reader:
                if int(row[9]) == 1: #tracking error
                    data_list.append(data_list[-1]) #interpolate by copying last frame
                else:
                    row[2] = int(row[2])/pix2cm
                    row[3] = int(row[3])/pix2cm
                    row[6] = int(row[6])
                    if tracktype=='room':
                        row[2] = row[2]-center
                        row[3] = row[3]-center
                    data_list.append(row) #read tracking data into a list
    return data_list
    
#find angle between position & lines defining the shock borders
def angle_from_shock(v2): #returns values between 0 and -2pi
    v1 = [0,41] #[33.57568,23.53028]
    dot = v1[0]*v2[0] + v1[1]*v2[1]
    det = v1[0]*v2[1] - v1[1]*v2[0]
    angle = math.atan2(det,dot)
    if v2[0]<0: #x is negative, so more than 180 deg away from shock border
        angle = angle - 2*math.pi
    return angle

framestep = 30 #30 frames/s
bin_size = 1*framestep #1 second. can be changed to smooth
pix2cm = 3.122 #translate x & y into cm
center = 127.5/pix2cm
#shock zone is between 90 and 150 deg on unit circle
#multiply by radius (41cm) to get border points along edge of arena
shock_border1 = [0,41]
#shock_border2 = [-35.67,20.5]
#shock zone is between 60 and 120 on unit circle
#shock_border1 = [33.57568,23.53028]
trackdir = trackdir.replace('\\','/') #python doesn't like unescaped chars

with open(trackdir+'/'+outputfile,'wb') as csvfile:
    writer = csv.writer(csvfile, delimiter=',') #open output file
    writer.writerow(['Mouse','Trial',
        'Avg Dist to SZ at Bout Start (cm)','Avg Dist to SZ at Bout Start (rad)',
        'Total Path Len (cm)','Total Angular Path Len (rad)','% Path Clockwise','Len Path Clockwise (rad)',
        '# of Bouts','# Bouts Clockwise','% Bouts Clockwise',
        '% Avoid Bouts','Avg Bout Path Len (cm)','Avg Bout Ang Path Len (rad)',
        'Avg Travel Away from SZ (cm)','Avg Travel Away from SZ (rad)',
        '# Escape Bouts','Avg Bout Path Len (cm)','Avg Bout Ang Path Len (rad)',
        'Avg Travel Away from SZ (cm)','Avg Travel Away from SZ (rad)',
        '# Avoid Bouts','Avg Bout Path Len (cm)','Avg Bout Ang Path Len (rad)',
        'Avg Travel Away from SZ (cm)','Avg Travel Away from SZ (rad)',
        '# Walk Bouts','Avg Bout Path Len (cm)','Avg Bout Ang Path Len (rad)',
        'Avg Travel Away from SZ (cm)','Avg Travel Away from SZ (rad)']) #add column titles

    for tracking_file in os.listdir(trackdir): #iterate over all files in the folder
        if tracking_file.startswith('ArenaTrack'): #for each trial
            
            #read csv files to a list structure
            arena_file = tracking_file
            match_group = re.match('ArenaTrack_(\d{1,3})_(.{1,5})_(.*)Arena.dat',arena_file)
                #(\d{1,3}) means a 1-3 digit number, the mouse blind code (eg 102)
                #(.{1,3}) means a 1-3 character string, the trial type (eg T01)
            mouse = match_group.group(1) #extract mouse # and trial name from file
            trial = match_group.group(2)
            suffix = match_group.group(3)
            
            arena_tracking = read_tracking(trackdir+'/'+arena_file) #read tracking file into an object
            room_file = 'RoomTrack_'+mouse+'_'+trial+'_'+suffix+'Room.dat'
            room_tracking = read_tracking(trackdir+'/'+room_file,tracktype='room') #read the corresponding room tracking file
            
    
            #calculate linear & angular velocities at each second
            velocities = list()
            angles = list()
            for i in range(int(len(arena_tracking)/30)-1): #1s bins to smooth tracking jitter
                dist = math.sqrt(((arena_tracking[i*framestep][2]-arena_tracking[(i+1)*framestep][2])**2)
                            +((arena_tracking[i*framestep][3]-arena_tracking[(i+1)*framestep][3])**2))
                velocities.append(dist)
                
                v1 = [room_tracking[i*framestep][2],room_tracking[i*framestep][3]] 
                v2 = [room_tracking[(i+1)*framestep][2],room_tracking[(i+1)*framestep][3]]
                angle1 = angle_from_shock(v1)
                angle2 = angle_from_shock(v2)
                angles.append(angle2-angle1)
                
                
            #calculate bouts     
            last_zero = 0
            last_nonzero = 0
            bouts = list()
            for i in range(1,len(velocities)): 
                if velocities[i]<2: #2cm/s, tracking jitter & small movements
                    if last_nonzero == i-1 and i-last_zero > 2: #just ended a bout
                        dist_travelled = sum(velocities[last_zero+1:i-1])
                        dist_travelled_ang = sum([abs(a) for a in angles[last_zero+1:i-1]])
                        r = (i-1)*framestep-1
                        
                        #find angle between position & lines defining the shock borders
                        point = [room_tracking[r][2], room_tracking[r][3]]
                        delta_dist_to_shock_ang = angle_from_shock(point) - dist_to_shock_ang
                        #find shortest distance between position & lines defining the shock borders
                        point = [p*-1 for p in point]
                        dist1 = numpy.linalg.norm(numpy.cross(shock_border1,point))/numpy.linalg.norm(shock_border1)
                        delta_dist_to_shock = dist1 - dist_to_shock
                    
                        bout_length = i - last_zero - 2
                        bouts.append(Bout(escape, avoid, dist_to_shock, dist_to_shock_ang, dist_travelled,
                        dist_travelled_ang, delta_dist_to_shock, delta_dist_to_shock_ang, bout_length, time_since_last_bout))
                    last_zero = i
                    
                elif i==len(velocities)-1: #last second of trial
                    dist_travelled = sum(velocities[last_zero+1:i])
                    dist_travelled_ang = sum(angles[last_zero+1:i])
                    r = i*framestep-1
                    
                    #find angle between position & lines defining the shock borders
                    point = [room_tracking[r][2], room_tracking[r][3]]
                    delta_dist_to_shock_ang = angle_from_shock(point) - dist_to_shock_ang
                    #find shortest distance between position & lines defining the shock borders
                    point = [p*-1 for p in point]
                    dist1 = numpy.linalg.norm(numpy.cross(shock_border1,point))/numpy.linalg.norm(shock_border1)
                    delta_dist_to_shock = dist1 - dist_to_shock

                    bout_length = i - last_zero - 1
                    bouts.append(Bout(escape, avoid, dist_to_shock, dist_to_shock_ang, dist_travelled,
                                dist_travelled_ang, delta_dist_to_shock, delta_dist_to_shock_ang, bout_length, time_since_last_bout))
                        
                else:
                    if last_zero == i-1: #new bout
                        time_since_last_bout = i-last_nonzero #seconds of immobility
                        escape = 0
                        #if mouse was shocked in current or prior second, bout is 'escape' type
                        for r in range((i-1)*framestep,(i+1)*framestep-1):
                            if arena_tracking[r][6] == 2:
                                escape = 1
                                break
            
                        avoid = 0
                        dist_to_shock = float('inf')
                        dist_to_shock_ang = float('inf')
                        #within current or prior second, find closest approach to shock zone
                        for r in range((i-1)*framestep,(i+1)*framestep-1):
                            #find angle between position & lines defining the shock borders
                            point = [room_tracking[r][2], room_tracking[r][3]]
                            dist_to_shock_ang = min(dist_to_shock_ang, angle_from_shock(point))
                            #find shortest distance between position & lines defining the shock borders
                            point = [p*-1 for p in point]
                            dist1 = numpy.linalg.norm(numpy.cross(shock_border1,point))/numpy.linalg.norm(shock_border1)
                            dist_to_shock = min(dist_to_shock, dist1)

                        #if came within 60deg (10s of rotation) of shock border but didn't get shocked, bout is 'avoid' type
                        if dist_to_shock_ang>-1*math.radians(60) and escape!=1:
                            avoid = 1
                    last_nonzero = i
                            
            
            #save to csv    
            dist_to_shock_list = list()
            dist_to_shock_ang_list = list()
            dist_total = list()
            angle_total = list()
            fromshock_total = list()
            fromshockang_total = list()
            num_clockwise_bouts = 0
            num_escape = 0
            num_avoid = 0 
            num_walk = 0
            dist_escape = list()
            angle_escape = list()
            fromshock_escape = list()
            fromshockang_escape = list()
            dist_avoid = list()
            angle_avoid = list()
            fromshock_avoid = list()
            fromshockang_avoid = list()
            dist_walk = list()
            angle_walk = list()
            fromshock_walk = list()
            fromshockang_walk = list()
            for b in bouts:
                dist_to_shock_list.append(b.dist_to_shock)
                dist_to_shock_ang_list.append(b.dist_to_shock_ang)
                dist_total.append(b.dist_travelled)
                angle_total.append(b.dist_travelled_ang)
                fromshock_total.append(b.delta_dist_to_shock)
                fromshockang_total.append(b.delta_dist_to_shock_ang)
                if b.delta_dist_to_shock_ang<0: #clockwise
                    num_clockwise_bouts+=1
                if b.escape==1:
                    num_escape+=1
                    dist_escape.append(b.dist_travelled)
                    angle_escape.append(b.dist_travelled_ang)
                    fromshock_escape.append(b.delta_dist_to_shock)
                    fromshockang_escape.append(b.delta_dist_to_shock_ang)
                elif b.avoid==1:
                    num_avoid+=1
                    dist_avoid.append(b.dist_travelled)
                    angle_avoid.append(b.dist_travelled_ang)
                    fromshock_avoid.append(b.delta_dist_to_shock)
                    fromshockang_avoid.append(b.delta_dist_to_shock_ang)
                else:
                    num_walk+=1
                    dist_walk.append(b.dist_travelled)
                    angle_walk.append(b.dist_travelled_ang)
                    fromshock_walk.append(b.delta_dist_to_shock)
                    fromshockang_walk.append(b.delta_dist_to_shock_ang)
                    
            num_clockwise = 0
            len_clockwise = 0
            for a in angles:
                if a < 0:
                    num_clockwise+=1
                    len_clockwise+=a
                    
            #write to row of csv file
            #max(angle_avoid or [-1])
            writer.writerow([mouse, trial, 
                numpy.mean(dist_to_shock_list), numpy.mean(dist_to_shock_ang_list), 
                sum(velocities), sum([abs(a) for a in angles]), float(num_clockwise)/len(angles), len_clockwise,
                len(bouts), num_clockwise_bouts, float(num_clockwise_bouts)/len(bouts), 
                float(num_avoid)/(num_avoid+num_walk), numpy.mean(dist_total), numpy.mean(angle_total),
                numpy.mean(fromshock_total), numpy.mean(fromshockang_total), 
                num_escape, numpy.mean(dist_escape), numpy.mean(angle_escape),
                numpy.mean(fromshock_escape), numpy.mean(fromshockang_escape), 
                num_avoid, numpy.mean(dist_avoid), numpy.mean(angle_avoid),
                numpy.mean(fromshock_avoid), numpy.mean(fromshockang_avoid), 
                num_walk, numpy.mean(dist_walk), numpy.mean(angle_walk),
                numpy.mean(fromshock_walk), numpy.mean(fromshockang_walk)])