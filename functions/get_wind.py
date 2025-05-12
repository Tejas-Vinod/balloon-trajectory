# interpolate wind data for uwind and vwind

import pandas as pd
from scipy.interpolate import LinearNDInterpolator
import numpy as np
from collections import OrderedDict

#function to reduce the data for interpolation
def reduce(df,input,flight_status,reduce_var):
    #data reduction for latitude
    var = 'latitude'
    df_interp1 = df.iloc[(df[var] - input[0]).abs().argsort()]
    interp_lat = df_interp1[var].tolist()
    interp_lat = list(OrderedDict.fromkeys(interp_lat))[:2]

    var = 'longitude'
    df_interp2 = df.iloc[(df[var] - input[1]).abs().argsort()]
    interp_lon = df_interp2[var].tolist()
    interp_lon = list(OrderedDict.fromkeys(interp_lon))[:2]

    #filter to data with nearest lat lon coordinates
    df = df.loc[(df['latitude'].isin(interp_lat)) & (df['longitude'].isin(interp_lon))]

    #reduce for time
    var = 'forecast_time_unix'
    df_interp3 = df.iloc[(df[var] - input[3]).abs().argsort()]
    interp_time = df_interp3[var].tolist()
    interp_time = list(OrderedDict.fromkeys(interp_time))[:2]
    interp_time.sort()

    #filter to relevant data for nearest times
    df = df.loc[(df[var].isin(interp_time))]

    #reduce for altitude
    try: #try catch currently: if altitude is lower than lowest forecast data
    ##########
    #NEED TO FIX THE TRY, EXCEPT TO HANDLE DIFFERENT LOW ALTITUDE OR HIGH PRESSURE (LOW ALT) OR OUT OF BOUNDS LAT/LON 
    ##########
        var = reduce_var #geopotenial height from grib2 data in gpm or isoBar pressure in Pa
        corners = [[interp_lat[0],interp_lon[0]],
                [interp_lat[0],interp_lon[1]],
                [interp_lat[1],interp_lon[0]],
                [interp_lat[1],interp_lon[1]]]

        reduced_df = pd.DataFrame()
        for t in range(len(interp_time)):
            if flight_status == 'ascent' or (flight_status == 'float' and var == 'HGT'):
                #alt < target alt
                for i in range(np.shape(corners)[0]):
                    below = df.loc[(df['latitude'] == corners[i][0]) & (df['longitude'] == corners[i][1]) & (df['forecast_time_unix'] == interp_time[t]) & (df[var] < input[2])]
                    new_row = below.iloc[[0]]
                    reduced_df = pd.concat([reduced_df,new_row])
                #alt >= target alt
                for i in range(np.shape(corners)[0]):
                    above = df.loc[(df['latitude'] == corners[i][0]) & (df['longitude'] == corners[i][1]) & (df['forecast_time_unix'] == interp_time[t]) & (df[var] >= input[2])]
                    new_row = above.iloc[[-1]]
                    reduced_df = pd.concat([reduced_df,new_row])

            if flight_status == 'descent':
                #alt > target alt
                for i in range(np.shape(corners)[0]):
                    above = df.loc[(df['latitude'] == corners[i][0]) & (df['longitude'] == corners[i][1]) & (df['forecast_time_unix'] == interp_time[t]) & (df[var] > input[2])]
                    # print(above)
                    new_row = above.iloc[[-1]]
                    reduced_df = pd.concat([reduced_df,new_row])
                #alt <= target alt
                for i in range(np.shape(corners)[0]):
                    below = df.loc[(df['latitude'] == corners[i][0]) & (df['longitude'] == corners[i][1]) & (df['forecast_time_unix'] == interp_time[t]) & (df[var] <= input[2])]
                    new_row = below.iloc[[0]]
                    reduced_df = pd.concat([reduced_df,new_row])

            #for selecting the correct pressures - opposite order of altitude or winds
            if flight_status == 'float' and var == 'isoBar_Pa':
                #alt < target alt
                for i in range(np.shape(corners)[0]):
                    below = df.loc[(df['latitude'] == corners[i][0]) & (df['longitude'] == corners[i][1]) & (df['forecast_time_unix'] == interp_time[t]) & (df[var] < input[2])]
                    new_row = below.iloc[[-1]]
                    reduced_df = pd.concat([reduced_df,new_row])
                #alt >= target alt
                for i in range(np.shape(corners)[0]):
                    above = df.loc[(df['latitude'] == corners[i][0]) & (df['longitude'] == corners[i][1]) & (df['forecast_time_unix'] == interp_time[t]) & (df[var] >= input[2])]
                    new_row = above.iloc[[0]]
                    reduced_df = pd.concat([reduced_df,new_row])

        to_low = False
    except:
        # print(f"Below wind data altitude at {input[2]}")
        to_low = True
        reduced_df = df

    return interp_lat,interp_lon,interp_time,reduced_df,to_low


#function to interpolate with lat/lon/alt
def interp1(rdf,target_coord):
    #target coord [lat,lon,alt]
    interp_t = rdf.to_numpy()
    
    lats_t = interp_t[:,5] #latitude
    lons_t = interp_t[:,6] #longitude
    alts_t = interp_t[:,0] #HGT 

    uwind_t = interp_t[:,1] #uwind
    vwind_t = interp_t[:,2] #vwind
    # temps_t = interp_t[:,3] #temperature
    pressures_t = interp_t[:,4] #pressure isoBar in Pa

    #interpolate for winds and pressure
    coords_t = list(zip(lats_t,lons_t,alts_t))
    interp_t_uwind = LinearNDInterpolator(coords_t,uwind_t,rescale=True)
    uwind = interp_t_uwind(target_coord)

    interp_t_vwind = LinearNDInterpolator(coords_t,vwind_t,rescale=True)
    vwind = interp_t_vwind(target_coord)

    interp_t_pressure = LinearNDInterpolator(coords_t,pressures_t,rescale=True)
    pressure = interp_t_pressure(target_coord)

    return uwind,vwind,pressure

#function to interpolate with lat/lon/isoBar 
def interp1_pressure(rdf,target_coord):
    #target coord [lat,lon,isoBar]
    interp_t = rdf.to_numpy()
    
    lats_t = interp_t[:,5] #latitude
    lons_t = interp_t[:,6] #longitude
    alts_t = interp_t[:,0] #HGT 

    # uwind_t = interp_t[:,1] #uwind
    # vwind_t = interp_t[:,2] #vwind
    # temps_t = interp_t[:,3] #temperature
    pressures_t = interp_t[:,4] #pressure isoBar in Pa

    #interpolate for altitude
    coords_t = list(zip(lats_t,lons_t,pressures_t))
    interp_t_altitude = LinearNDInterpolator(coords_t,alts_t,rescale=True)
    altitude = interp_t_altitude(target_coord)
    return altitude

#function to interpolate with time: linear interpolation
def interp2(y0,y1,t0,t1,t):
    y = y0 + (t - t0)*((y1-y0)/(t1-t0))
    return y

#############################

#############################
#main function to interpolate wind
def get_wind(df,target,flight_status):
    #input [lat,long,alt,time]
    _, _,interp_time,rdf,to_low = reduce(df,target,flight_status,'HGT')

    #interpolation with lat/lon/alt
    if not (to_low):
        target_coord = np.array([target[:3]])
        uwind = np.empty([2,])
        vwind = np.empty([2,])
        for t in range(2):
            rdf_t = rdf.loc[rdf['forecast_time_unix'] == interp_time[t]]
            uwind[t],vwind[t],_ = interp1(rdf_t,target_coord)
        #linear interpolation with time (target[3])
        UWIND = interp2(uwind[0],uwind[1],interp_time[0],interp_time[1],target[3])
        VWIND = interp2(vwind[0],vwind[1],interp_time[0],interp_time[1],target[3])
    elif to_low:
        #############
        #not correct now: thinking of how to interpolate using only the lowest alt pts, lat, lon, time to figure out wind data and supplement that to the ground
        #############
        UWIND = rdf['UWind'].iloc[-1]
        VWIND = rdf['VWind'].iloc[-1]

    #sanity check
    # print(uwind,vwind)

    return UWIND,VWIND

#main function to interpolate pressure
def get_pressure(df,target,flight_status):
    #target is [lat,lon,alt,time]
    _, _,interp_time,rdf,to_low = reduce(df,target,flight_status,'HGT')

    #interpolation with lat/lon/alt
    if not (to_low):
        target_coord = np.array([target[:3]])
        
        pressure = np.empty([2,])
        for t in range(2):
            rdf_t = rdf.loc[rdf['forecast_time_unix'] == interp_time[t]]
            _,_,pressure[t] = interp1(rdf_t,target_coord)

        #linear interpolation with time (target[3])
        PRESSURE = interp2(pressure[0],pressure[1],interp_time[0],interp_time[1],target[3])
    elif to_low:
        #############
        #not correct now: thinking of how to interpolate using only the lowest alt pts, lat, lon, time to figure out wind data and supplement that to the ground
        ##############
        PRESSURE = rdf['isoBar_Pa'.iloc[0]]

    return PRESSURE


#main function to interpolate altitude
def get_altitude(df,target,flight_status):
    #target [lat,lon,isoBar,time]
    _, _,interp_time,rdf,to_low = reduce(df,target,flight_status,'isoBar_Pa')
    #interpolation with lat/lon/isoBar

    if not (to_low):
        target_coord = np.array([target[:3]])
        altitude = np.empty([2,])
        for t in range(2):
            rdf_t = rdf.loc[rdf['forecast_time_unix'] == interp_time[t]]
            altitude[t] = interp1_pressure(rdf_t,target_coord)

        #linear interpolation with time (target[3])
        ALTITUDE = interp2(altitude[0],altitude[1],interp_time[0],interp_time[1],target[3])
    elif to_low:
        ALTITUDE = rdf['HGT'].iloc[-1]


    return ALTITUDE




interpres = get_wind(dataframe, target, status)