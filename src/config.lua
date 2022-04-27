--[[
   
--]]

Config = {
    -- Displays the different data where problems could occur (for developers only)
    debugMode = false,

    -- ID of the control to open the menu | 51 = E
    controlOpenMenu = 51,


    -- distance the player must be to open the menu from the coordinates
    useDistance = 1.5,
    --[[ 
        Transactions made between the current day the player opens the menu and the current day minus lastTransactionDays
        IMPORTANT: Maximum: 30
        (Example: by default it is set to 4 so only transactions made up to 4 days ago will be displayed)
    --]] 
    lastTransactionDays = 15,
    --[[ 
        Max number of transactions displayed in the transaction history
        WARNING: This also impacts the calculation of earnings + expenses (the lower the number, the less transaction history it will be able to retrieve, do not set it too high to avoid overloading the cache and the database)
    --]] 
    transactionsLimitHistory = 200,
    -- ATM / Bank points

    -- Starting money on the personal bank account (when it is created)
    startPersonalAccountMoney = 10000,

    --[[
        Allows to display the blips of the banks on the map
    ]]
    showBlips = true,
    
    waypoints = {
        -- ATMS
        vector3(-3026.5, 70.531, 12.902),
        vector3(146.91, -1035.42, 29.34),
        vector3(-1053.639, -2843.17, 27.709),
        vector3(-386.733, 6045.953, 31.501),
        vector3(-284.037, 6224.385, 31.187),
        vector3(-284.037, 6224.385, 31.187),
        vector3(-132.999, 6366.491, 31.475),
        vector3(-110.753, 6467.703, 31.784),
        vector3(-94.9690, 6455.301, 31.784),
        vector3(155.4300, 6641.991, 31.784),
        vector3(174.6720, 6637.218, 31.784),
        vector3(1703.138, 6426.783, 32.730),
        vector3(1735.114, 6411.035, 35.164),
        vector3(1702.842, 4933.593, 42.051),
        vector3(1967.333, 3744.293, 32.272),
        vector3(1821.917, 3683.483, 34.244),
        vector3(1174.532, 2705.278, 38.027),
        vector3(540.0420, 2671.007, 42.177),
        vector3(2564.399, 2585.100, 38.016),
        vector3(2558.683, 349.6010, 108.050),
        vector3(2558.051, 389.4817, 108.660),
        vector3(1077.692, -775.796, 58.218),
        vector3(1139.018, -469.886, 66.789),
        vector3(1168.975, -457.241, 66.641),
        vector3(1153.884, -326.540, 69.245),
        vector3(381.2827, 323.2518, 103.270),
        vector3(236.4638, 217.4718, 106.840),
        vector3(265.0043, 212.1717, 106.780),
        vector3(285.2029, 143.5690, 104.970),
        vector3(157.7698, 233.5450, 106.450),
        vector3(-164.568, 233.5066, 94.919),
        vector3(-1827.04, 785.5159, 138.020),
        vector3(-1409.39, -99.2603, 52.473),
        vector3(-1205.35, -325.579, 37.870),
        vector3(-1215.64, -332.231, 37.881),
        vector3(-2072.41, -316.959, 13.345),
        vector3(-2975.72, 379.7737, 14.992),
        vector3(-2962.60, 482.1914, 15.762),
        vector3(-2955.70, 488.7218, 15.486),
        vector3(-3044.22, 595.2429, 7.595),
        vector3(-3144.13, 1127.415, 20.868),
        vector3(-3241.10, 996.6881, 12.500),
        vector3(-3241.11, 1009.152, 12.877),
        vector3(-1305.40, -706.240, 25.352),
        vector3(-538.225, -854.423, 29.234),
        vector3(-711.156, -818.958, 23.768),
        vector3(-717.614, -915.880, 19.268),
        vector3(-526.566, -1222.90, 18.434),
        vector3(-256.831, -719.646, 33.444),
        vector3(-203.548, -861.588, 30.205),
        vector3(112.4102, -776.162, 31.427),
        vector3(112.9290, -818.710, 31.386),
        vector3(119.9000, -883.826, 31.191),
        vector3(149.4551, -1038.95, 29.366),
        vector3(-846.304, -340.402, 38.687),
        vector3(-1204.35, -324.391, 37.877),
        vector3(-1216.27, -331.461, 37.773),
        vector3(-56.1935, -1752.53, 29.452),
        vector3(-261.692, -2012.64, 30.121),
        vector3(-273.001, -2025.60, 30.197),
        vector3(314.187, -278.621, 54.170),
        vector3(-351.534, -49.529, 49.042),
        vector3(24.589, -946.056, 29.357),
        vector3(-254.112, -692.483, 33.616),
        vector3(-1570.197, -546.651, 34.955),
        vector3(-1415.909, -211.825, 46.500),
        vector3(-1430.112, -211.014, 46.500),
        vector3(33.232, -1347.849, 29.497),
        vector3(129.85, -1296.25, 29.27),
        vector3(287.645, -1282.646, 29.659),
        vector3(289.012, -1256.545, 29.440),
        vector3(295.839, -895.640, 29.217),
        vector3(1686.753, 4815.809, 42.008),
        vector3(-302.408, -829.945, 32.417),
        vector3(5.134, -919.949, 29.557),
        vector3(527.26, -160.76, 57.09),

        vector3(-867.19, -186.99, 37.84),
        vector3(-821.62, -1081.88, 11.13),
        vector3(-1315.32, -835.96, 16.96),
        vector3(-660.71, -854.06, 24.48),
        vector3(-1109.73, -1690.81, 4.37),
        vector3(-1091.5, 2708.66, 18.95),
        vector3(1171.98, 2702.55, 38.18),
        vector3(2683.09, 3286.53, 55.24),
        vector3(89.61, 2.37, 68.31),
        vector3(-30.3, -723.76, 44.23),
        vector3(-28.07, -724.61, 44.23),
        vector3(-613.24, -704.84, 31.24),
        vector3(-618.84, -707.9, 30.5),
        vector3(-1289.23, -226.77, 42.45),
        vector3(-1285.6, -224.28, 42.45),
        vector3(-1286.24, -213.39, 42.45),
        vector3(-1282.54, -210.45, 42.45),
        vector3(472.34, -1001.67, 30.69),
        vector3(468.19, -990.62, 26.27),
        vector3(-587.07, -141.99, 47.2),
        vector3(187.48, -899.82, 30.71),
        vector3(929.903, 29.302, 71.834),
        vector3(903.576, -152.59, 74.147),
        vector3(-218.768, -1320.504, 30.89),

        -- Banks
        vector3(-1040.67, -2846.026, 27.717),
        vector3(150.266, -1040.203, 29.374),
        vector3(-1212.980, -330.841, 37.787),
        vector3(-2962.582, 482.627, 15.703),
        vector3(-112.202, 6469.295, 31.626),
        vector3(314.187, -278.621, 54.170),
        vector3(-351.534, -49.529, 49.042),
        vector3(241.727, 220.706, 106.286),
        vector3(1175.0643310547, 2706.6435546875, 38.094036102295),
        vector3(-537.293, -171.543, 38.22),
        vector3(-527.71, -166.219, 38.23),
        vector3(315.253, -593.718, 43.284),
    },

    blips = {
        vector3(150.266, -1040.203, 29.374),
        vector3(-1212.980, -330.841, 37.787),
        vector3(-2962.582, 482.627, 15.703),
        vector3(-112.202, 6469.295, 31.626),
        vector3(314.187, -278.621, 54.170),
        vector3(-351.534, -49.529, 49.042),
        vector3(241.727, 220.706, 106.286),
        vector3(1175.0643310547, 2706.6435546875, 38.094036102295)
    },
    --[[ 
        The different types of services displayed in the transaction history
        
        ATTENTION: DO NOT CHANGE THE ORDER, EACH LOCATION CREATES AN ID
        LEAVE THE FIRST ONES AS THEY ARE (YOU CAN ONLY CHANGE THE NAME + ICON)

        THE ICONS MUST BE OF THE SAME COLOR FOR A BETTER RENDERING
    --]]
    servicesType = {
        {
            name = "ATM",
            icon = "icons/atm.svg"
        },
        {
            name = "Transfer",
            icon = "icons/atm.svg"
        },
        {
            name = "Society",
            icon = "icons/briefcase.svg"
        },
        {
            name = "Car Dealer",
            icon = "icons/car.svg"
        },
        {
            name = "Real Estate Agency",
            icon = "icons/briefcase.svg"
        },
        {
            name = "EMS",
            icon = "icons/truck-medical-solid.svg"
        },
        {
            name = "Driving school",
            icon = "icons/driving-school.svg"
        },
        {
            name = "Gas Station",
            icon = "icons/gas-pump.svg"
        },
        {
            name = "Government",
            icon = "icons/birefcase.svg"
        },
    }
}