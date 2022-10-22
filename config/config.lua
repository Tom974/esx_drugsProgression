Config = {
    Locale = 'nl',
    npcs = {
        -- { x, y, z, kijkrichting, model hash, ped model, type ped, animatie info }
        {x=-30.8967, y=-706.2725, z=250.4, h=212.598420, modelHash=0xC99F21C4, pedModel="a_m_y_business_01", pedAnimation="mini@strip_club@idles@bouncer@base", pedInfo="weed", stepNumber=1, waypointX=487.55, waypointY=5589.09, waypointZ=794.05}, -- wiet
        {x=-22.48351, y=-704.2681, z=250.4, h=276.07, modelHash=0xC99F21C4, pedModel="a_m_y_business_01", pedAnimation="mini@strip_club@idles@bouncer@base", pedInfo="weed", stepNumber=2}, -- wiet
        {x=-29.60439, y=-699.244, z=250.4, h=12.1, modelHash=0xC99F21C4, pedModel="a_m_y_business_01", pedAnimation="mini@strip_club@idles@bouncer@base", pedInfo="weed", stepNumber=3}, -- eind-npc-wiet
        -- extra npc toevoegen
        {x=-14.22857, y=-700.4308, z=250.4, h=212.598420, modelHash=0xC99F21C4, pedModel="a_m_y_business_01", pedAnimation="mini@strip_club@idles@bouncer@base", pedInfo="coke", stepNumber=1, waypointX=487.55, waypointY=5589.09, waypointZ=794.05}, -- wiet
        {x=-18.3033, y=-692.4264, z=250.4, h=212.598420, modelHash=0xC99F21C4, pedModel="a_m_y_business_01", pedAnimation="mini@strip_club@idles@bouncer@base", pedInfo="coke", stepNumber=2}, -- wiet
        {x=-8.610985, y=-697.8066, z=250.4, h=12.1, modelHash=0xC99F21C4, pedModel="a_m_y_business_01", pedAnimation="mini@strip_club@idles@bouncer@base", pedInfo="coke", stepNumber=3} -- eind-npc-wiet
        
        -- {x=501.45, y=5603.81, z=797.91, h=212.598420, modelHash=0xC99F21C4, pedModel="a_m_y_business_01", pedAnimation="mini@strip_club@idles@bouncer@base", pedInfo="weed", stepNumber=1}, -- coke
        -- {x=487.55, y=5589.09, z=794.05, h=276.07, modelHash=0xC99F21C4, pedModel="a_m_y_business_01", pedAnimation="mini@strip_club@idles@bouncer@base", pedInfo="weed", stepNumber=2}, -- coke
        -- {x=501.45, y=5603.81, z=797.91, h=212.598420, modelHash=0xC99F21C4, pedModel="a_m_y_business_01", pedAnimation="mini@strip_club@idles@bouncer@base", pedInfo="weed", stepNumber=1}, -- meth
        -- {x=487.55, y=5589.09, z=794.05, h=276.07, modelHash=0xC99F21C4, pedModel="a_m_y_business_01", pedAnimation="mini@strip_club@idles@bouncer@base", pedInfo="weed", stepNumber=2}, -- meth
        
    },
    itemsToHave = { -- Items die je op zak moet hebben om een formule in te kunnen leveren
        weed = {
            {item="water", amount=1}
        },
        coke = {
            {item="water", amount=1}
        },
        meth = {
            {item="water", amount=1}
        }
    },
    displayDistance = 2.0,
    drugsPrices = {
        weed = 20000,
        coke = 100000,
        meth = 250000,
    },
    animations = {
        weed = 'world_human_gardener_plant',
        coke = 'prop_human_bum_bin',
        meth = 'prop_human_bum_bin'
    },
    lang = {
        drug_type = {
            weed = "Wiet",
            coke = "Coke",
            meth = "Meth"
        }
    }
}