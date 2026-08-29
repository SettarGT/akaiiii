Config = {}
Config.Keybind = 'F1'           -- FiveM Keyboard, this is registered keymapping, so needs changed in keybindings if player already has this mapped.
Config.Toggle = false           -- use toggle mode. False requires hold of key
Config.UseWhilstWalking = false -- use whilst walking
Config.EnableExtraMenu = true
Config.Fliptime = 15000

Config.MenuItems = {
    {
        id = 'citizen',
        title = 'Vətəndaş',
        icon = 'user',
        items = {
            {
                id = 'givenum',
                title = 'Əlaqə məlumatlarını ver',
                icon = 'address-book',
                type = 'client',
                event = 'qb-phone:client:GiveContactDetails',
                shouldClose = true
            }, {
            id = 'getintrunk',
            title = 'Baqaja gir',
            icon = 'car',
            type = 'client',
            event = 'qb-trunk:client:GetIn',
            shouldClose = true
        }, {
            id = 'cornerselling',
            title = 'Künc satışı',
            icon = 'cannabis',
            type = 'client',
            event = 'qb-drugs:client:cornerselling',
            shouldClose = true
        }, {
            id = 'togglehotdogsell',
            title = 'Hotdog satışı',
            icon = 'hotdog',
            type = 'client',
            event = 'qb-hotdogjob:client:ToggleSell',
            shouldClose = true
        }, {
            id = 'interactions',
            title = 'Qarşılıqlı əlaqə',
            icon = 'triangle-exclamation',
            items = {
                {
                    id = 'handcuff',
                    title = 'Kəndir bağla',
                    icon = 'user-lock',
                    type = 'client',
                    event = 'police:client:CuffPlayerSoft',
                    shouldClose = true
                }, {
                id = 'playerinvehicle',
                title = 'Vasitəyə qoy',
                icon = 'car-side',
                type = 'client',
                event = 'police:client:PutPlayerInVehicle',
                shouldClose = true
            }, {
                id = 'playeroutvehicle',
                title = 'Vasitədən çıxar',
                icon = 'car-side',
                type = 'client',
                event = 'police:client:SetPlayerOutVehicle',
                shouldClose = true
            }, {
                id = 'stealplayer',
                title = 'Qarət et',
                icon = 'mask',
                type = 'client',
                event = 'police:client:RobPlayer',
                shouldClose = true
            }, {
                id = 'escort',
                title = 'Qaçır',
                icon = 'user-group',
                type = 'client',
                event = 'police:client:KidnapPlayer',
                shouldClose = true
            }, {
                id = 'escort2',
                title = 'Müşayiət et',
                icon = 'user-group',
                type = 'client',
                event = 'police:client:EscortPlayer',
                shouldClose = true
            }, {
                id = 'escort554',
                title = 'Giros götür',
                icon = 'child',
                type = 'client',
                event = 'A5:Client:TakeHostage',
                shouldClose = true
            }
            }
        }
        }
    },
    {
        id = 'general',
        title = 'Ümumi',
        icon = 'rectangle-list',
        items = {
            {
                id = 'house',
                title = 'Ev əlaqəsi',
                icon = 'house',
                items = {
                    {
                        id = 'givehousekey',
                        title = 'Ev açarlarını ver',
                        icon = 'key',
                        type = 'client',
                        event = 'qb-houses:client:giveHouseKey',
                        shouldClose = true
                    }, {
                    id = 'removehousekey',
                    title = 'Ev açarlarını sil',
                    icon = 'key',
                    type = 'client',
                    event = 'qb-houses:client:removeHouseKey',
                    shouldClose = true
                }, {
                    id = 'togglelock',
                    title = 'Qapı kilidini dəyiş',
                    icon = 'door-closed',
                    type = 'client',
                    event = 'qb-houses:client:toggleDoorlock',
                    shouldClose = true
                }, {
                    id = 'decoratehouse',
                    title = 'Evi bəzə',
                    icon = 'box',
                    type = 'client',
                    event = 'qb-houses:client:decorate',
                    shouldClose = true
                }, {
                    id = 'houseLocations',
                    title = 'Əlaqə yerləri',
                    icon = 'house',
                    items = {
                        {
                            id = 'setstash',
                            title = 'Anbar təyin et',
                            icon = 'box-open',
                            type = 'client',
                            event = 'qb-houses:client:setLocation',
                            shouldClose = true
                        }, {
                        id = 'setoutift',
                        title = 'Qarderob təyin et',
                        icon = 'shirt',
                        type = 'client',
                        event = 'qb-houses:client:setLocation',
                        shouldClose = true
                    }, {
                        id = 'setlogout',
                        title = 'Çıxışı təyin et',
                        icon = 'door-open',
                        type = 'client',
                        event = 'qb-houses:client:setLocation',
                        shouldClose = true
                    }
                    }
                }
                }
            }, {
            id = 'clothesmenu',
            title = 'Geyim',
            icon = 'shirt',
            items = {
                {
                    id = 'Saç',
                    title = 'Saç',
                    icon = 'user',
                    type = 'client',
                    event = 'qb-radialmenu:ToggleClothing',
                    shouldClose = true
                }, {
                id = 'Ear',
                title = 'Qulaqlıq',
                icon = 'ear-deaf',
                type = 'client',
                event = 'qb-radialmenu:ToggleProps',
                shouldClose = true
            }, {
                id = 'Boyun',
                title = 'Boyun',
                icon = 'user-tie',
                type = 'client',
                event = 'qb-radialmenu:ToggleClothing',
                shouldClose = true
            }, {
                id = 'Üst',
                title = 'Üst',
                icon = 'shirt',
                type = 'client',
                event = 'qb-radialmenu:ToggleClothing',
                shouldClose = true
            }, {
                id = 'Köynək',
                title = 'Köynək',
                icon = 'shirt',
                type = 'client',
                event = 'qb-radialmenu:ToggleClothing',
                shouldClose = true
            }, {
                id = 'Şalvar',
                title = 'Şalvar',
                icon = 'user',
                type = 'client',
                event = 'qb-radialmenu:ToggleClothing',
                shouldClose = true
            }, {
                id = 'Ayaqqabı',
                title = 'Ayaqqabı',
                icon = 'shoe-prints',
                type = 'client',
                event = 'qb-radialmenu:ToggleClothing',
                shouldClose = true
            }, {
                id = 'meer',
                title = 'Ekstralar',
                icon = 'plus',
                items = {
                    {
                        id = 'Papaq',
                        title = 'Papaq',
                        icon = 'hat-cowboy-side',
                        type = 'client',
                        event = 'qb-radialmenu:ToggleProps',
                        shouldClose = true
                    }, {
                    id = 'Eynək',
                    title = 'Eynək',
                    icon = 'glasses',
                    type = 'client',
                    event = 'qb-radialmenu:ToggleProps',
                    shouldClose = true
                }, {
                    id = 'Üst qapaq',
                    title = 'Üst qapaq',
                    icon = 'hat-cowboy-side',
                    type = 'client',
                    event = 'qb-radialmenu:ToggleProps',
                    shouldClose = true
                }, {
                    id = 'Maska',
                    title = 'Maska',
                    icon = 'masks-theater',
                    type = 'client',
                    event = 'qb-radialmenu:ToggleClothing',
                    shouldClose = true
                }, {
                    id = 'Jilet',
                    title = 'Jilet',
                    icon = 'vest',
                    type = 'client',
                    event = 'qb-radialmenu:ToggleClothing',
                    shouldClose = true
                }, {
                    id = 'Çanta',
                    title = 'Çanta',
                    icon = 'bag-shopping',
                    type = 'client',
                    event = 'qb-radialmenu:ToggleClothing',
                    shouldClose = true
                }, {
                    id = 'Bilərzik',
                    title = 'Bilərzik',
                    icon = 'user',
                    type = 'client',
                    event = 'qb-radialmenu:ToggleProps',
                    shouldClose = true
                }, {
                    id = 'Saat',
                    title = 'Saat',
                    icon = 'stopwatch',
                    type = 'client',
                    event = 'qb-radialmenu:ToggleProps',
                    shouldClose = true
                }, {
                    id = 'Əlcək',
                    title = 'Əlcək',
                    icon = 'mitten',
                    type = 'client',
                    event = 'qb-radialmenu:ToggleClothing',
                    shouldClose = true
                }
                }
            }
            }
        }
        }
    },
}

Config.VehicleDoors = {
    id = 'vehicledoors',
    title = 'Vasitə Qapıları',
    icon = 'car-side',
    items = {
        {
            id = 'door0',
            title = 'Sürücü qapısı',
            icon = 'car-side',
            type = 'client',
            event = 'qb-radialmenu:client:openDoor',
            shouldClose = false
        }, {
        id = 'door4',
        title = 'Kapot',
        icon = 'car',
        type = 'client',
        event = 'qb-radialmenu:client:openDoor',
        shouldClose = false
    }, {
        id = 'door1',
        title = 'Sərnişin qapısı',
        icon = 'car-side',
        type = 'client',
        event = 'qb-radialmenu:client:openDoor',
        shouldClose = false
    }, {
        id = 'door3',
        title = 'Sağ arxa',
        icon = 'car-side',
        type = 'client',
        event = 'qb-radialmenu:client:openDoor',
        shouldClose = false
    }, {
        id = 'door5',
        title = 'Baqaj',
        icon = 'car',
        type = 'client',
        event = 'qb-radialmenu:client:openDoor',
        shouldClose = false
    }, {
        id = 'door2',
        title = 'Sol arxa',
        icon = 'car-side',
        type = 'client',
        event = 'qb-radialmenu:client:openDoor',
        shouldClose = false
    }
    }
}

Config.VehicleExtras = {
    id = 'vehicleextras',
    title = 'Vasitə Ekstraları',
    icon = 'plus',
    items = {
        {
            id = 'extra1',
            title = 'Ekstra 1',
            icon = 'box-open',
            type = 'client',
            event = 'qb-radialmenu:client:setExtra',
            shouldClose = false
        }, {
        id = 'extra2',
        title = 'Ekstra 2',
        icon = 'box-open',
        type = 'client',
        event = 'qb-radialmenu:client:setExtra',
        shouldClose = false
    }, {
        id = 'extra3',
        title = 'Ekstra 3',
        icon = 'box-open',
        type = 'client',
        event = 'qb-radialmenu:client:setExtra',
        shouldClose = false
    }, {
        id = 'extra4',
        title = 'Ekstra 4',
        icon = 'box-open',
        type = 'client',
        event = 'qb-radialmenu:client:setExtra',
        shouldClose = false
    }, {
        id = 'extra5',
        title = 'Ekstra 5',
        icon = 'box-open',
        type = 'client',
        event = 'qb-radialmenu:client:setExtra',
        shouldClose = false
    }, {
        id = 'extra6',
        title = 'Ekstra 6',
        icon = 'box-open',
        type = 'client',
        event = 'qb-radialmenu:client:setExtra',
        shouldClose = false
    }, {
        id = 'extra7',
        title = 'Ekstra 7',
        icon = 'box-open',
        type = 'client',
        event = 'qb-radialmenu:client:setExtra',
        shouldClose = false
    }, {
        id = 'extra8',
        title = 'Ekstra 8',
        icon = 'box-open',
        type = 'client',
        event = 'qb-radialmenu:client:setExtra',
        shouldClose = false
    }, {
        id = 'extra9',
        title = 'Ekstra 9',
        icon = 'box-open',
        type = 'client',
        event = 'qb-radialmenu:client:setExtra',
        shouldClose = false
    }, {
        id = 'extra10',
        title = 'Ekstra 10',
        icon = 'box-open',
        type = 'client',
        event = 'qb-radialmenu:client:setExtra',
        shouldClose = false
    }, {
        id = 'extra11',
        title = 'Ekstra 11',
        icon = 'box-open',
        type = 'client',
        event = 'qb-radialmenu:client:setExtra',
        shouldClose = false
    }, {
        id = 'extra12',
        title = 'Ekstra 12',
        icon = 'box-open',
        type = 'client',
        event = 'qb-radialmenu:client:setExtra',
        shouldClose = false
    }, {
        id = 'extra13',
        title = 'Ekstra 13',
        icon = 'box-open',
        type = 'client',
        event = 'qb-radialmenu:client:setExtra',
        shouldClose = false
    }
    }
}

Config.VehicleSeats = {
    id = 'vehicleseats',
    title = 'Vasitə Yerləri',
    icon = 'chair',
    items = {}
}

Config.JobInteractions = {
    ['ambulance'] = {
        {
            id = 'statuscheck',
            title = 'Sağlamlıq vəziyyətini yoxla',
            icon = 'heart-pulse',
            type = 'client',
            event = 'hospital:client:CheckStatus',
            shouldClose = true
        }, {
        id = 'revivep',
        title = 'Dirilt',
        icon = 'user-doctor',
        type = 'client',
        event = 'hospital:client:RevivePlayer',
        shouldClose = true
    }, {
        id = 'treatwounds',
        title = 'Yaraları sağalt',
        icon = 'bandage',
        type = 'client',
        event = 'hospital:client:TreatWounds',
        shouldClose = true
    }, {
        id = 'emergencybutton2',
        title = 'Təcili kömək düyməsi',
        icon = 'bell',
        type = 'client',
        event = 'police:client:SendPoliceEmergencyAlert',
        shouldClose = true
    }, {
        id = 'escort',
        title = 'Müşayiət et',
        icon = 'user-group',
        type = 'client',
        event = 'police:client:EscortPlayer',
        shouldClose = true
    }, {
        id = 'stretcheroptions',
        title = 'Nosilki',
        icon = 'bed-pulse',
        items = {
            {
                id = 'spawnstretcher',
                title = 'Nosilki yarat',
                icon = 'plus',
                type = 'client',
                event = 'qb-radialmenu:client:TakeStretcher',
                shouldClose = false
            }, {
            id = 'despawnstretcher',
            title = 'Nosilki yığ',
            icon = 'minus',
            type = 'client',
            event = 'qb-radialmenu:client:RemoveStretcher',
            shouldClose = false
        }
        }
    }
    },
    ['taxi'] = {
        {
            id = 'togglemeter',
            title = 'Sayğacı göstər/gizlə',
            icon = 'eye-slash',
            type = 'client',
            event = 'qb-taxi:client:toggleMeter',
            shouldClose = false
        }, {
        id = 'togglemouse',
        title = 'Sayğacı başlat/dayandır',
        icon = 'hourglass-start',
        type = 'client',
        event = 'qb-taxi:client:enableMeter',
        shouldClose = true
    }, {
        id = 'npc_mission',
        title = 'NPC Missiyası',
        icon = 'taxi',
        type = 'client',
        event = 'qb-taxi:client:DoTaxiNpc',
        shouldClose = true
    }
    },
    ['tow'] = {
        {
            id = 'togglenpc',
            title = 'NPC-ni dəyiş',
            icon = 'toggle-on',
            type = 'client',
            event = 'jobs:client:ToggleNpc',
            shouldClose = true
        }, {
        id = 'towvehicle',
        title = 'Vasitəni yedəklə',
        icon = 'truck-pickup',
        type = 'client',
        event = 'qb-tow:client:TowVehicle',
        shouldClose = true
    }
    },
    ['mechanic'] = {
        {
            id = 'towvehicle',
            title = 'Vasitəni yedəklə',
            icon = 'truck-pickup',
            type = 'client',
            event = 'qb-tow:client:TowVehicle',
            shouldClose = true
        }
    },
    ['police'] = {
        {
            id = 'emergencybutton',
            title = 'Təcili kömək düyməsi',
            icon = 'bell',
            type = 'client',
            event = 'police:client:SendPoliceEmergencyAlert',
            shouldClose = true
        }, {
        id = 'checkvehstatus',
        title = 'Tuninq vəziyyətini yoxla',
        icon = 'circle-info',
        type = 'client',
        event = 'qb-tunerchip:client:TuneStatus',
        shouldClose = true
    }, {
        id = 'resethouse',
        title = 'Ev kilidini sıfırla',
        icon = 'key',
        type = 'client',
        event = 'qb-houses:client:ResetHouse',
        shouldClose = true
    }, {
        id = 'takedriverlicense',
        title = 'Sürücülük vəsiqəsini ləğv et',
        icon = 'id-card',
        type = 'client',
        event = 'police:client:SeizeDriverLicense',
        shouldClose = true
    }, {
        id = 'policeinteraction',
        title = 'Polis Əməliyyatları',
        icon = 'list-check',
        items = {
            {
                id = 'statuscheck',
                title = 'Sağlamlıq vəziyyətini yoxla',
                icon = 'heart-pulse',
                type = 'client',
                event = 'hospital:client:CheckStatus',
                shouldClose = true
            }, {
            id = 'checkstatus',
            title = 'Statusu yoxla',
            icon = 'question',
            type = 'client',
            event = 'police:client:CheckStatus',
            shouldClose = true
        }, {
            id = 'escort',
            title = 'Müşayiət et',
            icon = 'user-group',
            type = 'client',
            event = 'police:client:EscortPlayer',
            shouldClose = true
        }, {
            id = 'searchplayer',
            title = 'Axtar',
            icon = 'magnifying-glass',
            type = 'server',
            event = 'police:server:SearchPlayer',
            shouldClose = true
        }, {
            id = 'jailplayer',
            title = 'Həbs et',
            icon = 'user-lock',
            type = 'client',
            event = 'police:client:JailPlayer',
            shouldClose = true
        }
        }
    }, {
        id = 'policeobjects',
        title = 'Obyektlər',
        icon = 'road',
        items = {
            {
                id = 'spawnpion',
                title = 'Konus',
                icon = 'triangle-exclamation',
                type = 'client',
                event = 'police:client:spawnCone',
                shouldClose = false
            }, {
            id = 'spawnhek',
            title = 'Darvaza',
            icon = 'torii-gate',
            type = 'client',
            event = 'police:client:spawnBarrier',
            shouldClose = false
        }, {
            id = 'spawnschotten',
            title = 'Sürət həddi nişanı',
            icon = 'sign-hanging',
            type = 'client',
            event = 'police:client:spawnRoadSign',
            shouldClose = false
        }, {
            id = 'spawntent',
            title = 'Çadır',
            icon = 'campground',
            type = 'client',
            event = 'police:client:spawnTent',
            shouldClose = false
        }, {
            id = 'spawnverlichting',
            title = 'İşıqlandırma',
            icon = 'lightbulb',
            type = 'client',
            event = 'police:client:spawnLight',
            shouldClose = false
        }, {
            id = 'spikestrip',
            title = 'Tikanlı zolaq',
            icon = 'caret-up',
            type = 'client',
            event = 'police:client:SpawnSpikeStrip',
            shouldClose = false
        }, {
            id = 'deleteobject',
            title = 'Obyekti sil',
            icon = 'trash',
            type = 'client',
            event = 'police:client:deleteObject',
            shouldClose = false
        }
        }
    }
    },
    ['hotdog'] = {
        {
            id = 'togglesell',
            title = 'Satışı dəyiş',
            icon = 'hotdog',
            type = 'client',
            event = 'qb-hotdogjob:client:ToggleSell',
            shouldClose = true
        }
    }
}

Config.TrunkClasses = {
    [0] = { allowed = true, x = 0.0, y = -1.5, z = 0.0 },   -- Coupes
    [1] = { allowed = true, x = 0.0, y = -2.0, z = 0.0 },   -- Sedans
    [2] = { allowed = true, x = 0.0, y = -1.0, z = 0.25 },  -- SUVs
    [3] = { allowed = true, x = 0.0, y = -1.5, z = 0.0 },   -- Coupes
    [4] = { allowed = true, x = 0.0, y = -2.0, z = 0.0 },   -- Muscle
    [5] = { allowed = true, x = 0.0, y = -2.0, z = 0.0 },   -- Sports Classics
    [6] = { allowed = true, x = 0.0, y = -2.0, z = 0.0 },   -- Sports
    [7] = { allowed = true, x = 0.0, y = -2.0, z = 0.0 },   -- Super
    [8] = { allowed = false, x = 0.0, y = -1.0, z = 0.25 }, -- Motorcycles
    [9] = { allowed = true, x = 0.0, y = -1.0, z = 0.25 },  -- Off-road
    [10] = { allowed = true, x = 0.0, y = -1.0, z = 0.25 }, -- Industrial
    [11] = { allowed = true, x = 0.0, y = -1.0, z = 0.25 }, -- Utility
    [12] = { allowed = true, x = 0.0, y = -1.0, z = 0.25 }, -- Vans
    [13] = { allowed = true, x = 0.0, y = -1.0, z = 0.25 }, -- Cycles
    [14] = { allowed = true, x = 0.0, y = -1.0, z = 0.25 }, -- Boats
    [15] = { allowed = true, x = 0.0, y = -1.0, z = 0.25 }, -- Helicopters
    [16] = { allowed = true, x = 0.0, y = -1.0, z = 0.25 }, -- Planes
    [17] = { allowed = true, x = 0.0, y = -1.0, z = 0.25 }, -- Service
    [18] = { allowed = true, x = 0.0, y = -1.0, z = 0.25 }, -- Emergency
    [19] = { allowed = true, x = 0.0, y = -1.0, z = 0.25 }, -- Military
    [20] = { allowed = true, x = 0.0, y = -1.0, z = 0.25 }, -- Commercial
    [21] = { allowed = true, x = 0.0, y = -1.0, z = 0.25 }  -- Trains
}

Config.ExtrasEnabled = true

Config.Commands = {
    ['top'] = {
        Func = function() ToggleClothing('Üst') end,
        Sprite = 'top',
        Desc = 'Take your shirt off/on',
        Button = 1,
        Name = 'Torso'
    },
    ['gloves'] = {
        Func = function() ToggleClothing('gloves') end,
        Sprite = 'gloves',
        Desc = 'Take your gloves off/on',
        Button = 2,
        Name = 'Əlcək'
    },
    ['visor'] = {
        Func = function() ToggleProps('visor') end,
        Sprite = 'visor',
        Desc = 'Toggle hat variation',
        Button = 3,
        Name = 'Üst qapaq'
    },
    ['bag'] = {
        Func = function() ToggleClothing('Çanta') end,
        Sprite = 'bag',
        Desc = 'Opens or closes your bag',
        Button = 8,
        Name = 'Çanta'
    },
    ['shoes'] = {
        Func = function() ToggleClothing('Ayaqqabı') end,
        Sprite = 'shoes',
        Desc = 'Take your shoes off/on',
        Button = 5,
        Name = 'Ayaqqabı'
    },
    ['vest'] = {
        Func = function() ToggleClothing('Jilet') end,
        Sprite = 'vest',
        Desc = 'Take your vest off/on',
        Button = 14,
        Name = 'Jilet'
    },
    ['hair'] = {
        Func = function() ToggleClothing('hair') end,
        Sprite = 'hair',
        Desc = 'Put your hair up/down/in a bun/ponytail.',
        Button = 7,
        Name = 'Saç'
    },
    ['hat'] = {
        Func = function() ToggleProps('Papaq') end,
        Sprite = 'hat',
        Desc = 'Take your hat off/on',
        Button = 4,
        Name = 'Papaq'
    },
    ['glasses'] = {
        Func = function() ToggleProps('Eynək') end,
        Sprite = 'glasses',
        Desc = 'Take your glasses off/on',
        Button = 9,
        Name = 'Eynək'
    },
    ['ear'] = {
        Func = function() ToggleProps('Ear') end,
        Sprite = 'ear',
        Desc = 'Take your ear accessory off/on',
        Button = 10,
        Name = 'Ear'
    },
    ['neck'] = {
        Func = function() ToggleClothing('Boyun') end,
        Sprite = 'neck',
        Desc = 'Take your neck accessory off/on',
        Button = 11,
        Name = 'Boyun'
    },
    ['watch'] = {
        Func = function() ToggleProps('Saat') end,
        Sprite = 'watch',
        Desc = 'Take your watch off/on',
        Button = 12,
        Name = 'Saat',
        Rotation = 5.0
    },
    ['bracelet'] = {
        Func = function() ToggleProps('Bilərzik') end,
        Sprite = 'bracelet',
        Desc = 'Take your bracelet off/on',
        Button = 13,
        Name = 'Bilərzik'
    },
    ['mask'] = {
        Func = function() ToggleClothing('Maska') end,
        Sprite = 'mask',
        Desc = 'Take your mask off/on',
        Button = 6,
        Name = 'Maska'
    }
}

local bags = { [40] = true, [41] = true, [44] = true, [45] = true }

Config.ExtraCommands = {
    ['pants'] = {
        Func = function() ToggleClothing('Şalvar', true) end,
        Sprite = 'pants',
        Desc = 'Take your pants off/on',
        Name = 'Şalvar',
        OffsetX = -0.04,
        OffsetY = 0.0
    },
    ['shirt'] = {
        Func = function() ToggleClothing('Köynək', true) end,
        Sprite = 'shirt',
        Desc = 'Take your shirt off/on',
        Name = 'shirt',
        OffsetX = 0.04,
        OffsetY = 0.0
    },
    ['reset'] = {
        Func = function()
            if not ResetClothing(true) then
                Notify('Nothing To Reset', 'error')
            end
        end,
        Sprite = 'reset',
        Desc = 'Revert everything back to normal',
        Name = 'reset',
        OffsetX = 0.12,
        OffsetY = 0.2,
        Rotate = true
    },
    ['bagoff'] = {
        Func = function() ToggleClothing('Bagoff', true) end,
        Sprite = 'bagoff',
        SpriteFunc = function()
            local Bag = GetPedDrawableVariation(PlayerPedId(), 5)
            local BagOff = LastEquipped['Bagoff']
            if LastEquipped['Bagoff'] then
                if bags[BagOff.Drawable] then
                    return 'bagoff'
                else
                    return 'paraoff'
                end
            end
            if Bag ~= 0 then
                if bags[Bag] then
                    return 'bagoff'
                else
                    return 'paraoff'
                end
            else
                return false
            end
        end,
        Desc = 'Take your bag off/on',
        Name = 'bagoff',
        OffsetX = -0.12,
        OffsetY = 0.2
    }
}
