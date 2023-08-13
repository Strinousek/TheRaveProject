local RecentlyCalledOfficerTime = nil
local RecentlyCalledSupervisorTime = nil
local LawEnforcementJobs = exports.strin_jobs:GetLawEnforcementJobs()

local OngoingTests = {}

local CCW_TEST_PRESETS = {
    {
        {
            title = "Smrtící síla by se měla použít:",
            pointValue = 3,
            answers = {
                { "Kdykoli se cítíte ohroženi, i když je slovní hrozba." },
                { "Kdykoli jsou v nebezpečné čtvrti." },
                { "Pouze v případě bezprostřední hrozby smrti nebo těžké újmy na zdraví", true },
            }
        },
        {
            title = "Kdy je vhodné zacházet se střelnou zbraní?",
            pointValue = 2,
            answers = {
                { "Kdykoli se vám to bude hodit." },
                { "Na přeplněném veřejném místě." },
                { "Pouze v případě, že je to nutné pro sebeobranu.", true },
            }
        },
        {
            title = "Jaký je doporučený způsob přepravy střelné zbraně ve vozidle v San Andreas?",
            pointValue = 2,
            answers = {
                { "Mějte ji nabitou a na dosah ruky." },
                { "Umístěte ji na sedadlo spolujezdce, abyste k ní měli snadný přístup." },
                { "Vybitou jej uložte do uzamčeného kontejneru nebo kufru vozidla.", true },
            }
        },
        {
            title = "Může policie zabavit střelnou zbraň držiteli CCW Permitu, pokud existuje podezření, že byla použita k nezákonné činnosti?",
            pointValue = 2,
            answers = {
                { "Ne, policie nemůže zabavit legální střelné zbraně bez soudního příkazu." },
                { "Ano, ale pouze na 48 hodin." },
                { "Ano, pokud bude sloužit jako důkaz.", true },
            }
        },
        {
            title = "Jaká je vaše úloha a odpovědnost jako držitele CCW Permitu, pokud se stanete svědkem trestného činu při nošení skryté střelné zbraně?",
            pointValue = 1,
            answers = {
                { "Pokud je to možné, zasáhněte a zadržte podezřelého." },
                { "Zadržte podezřelého, dokud nepřijede policie." },
                { "Poskytněte policií podrobný popis a buďte dobrým svědkem.", true },
            }
        },
    },
    {
        {
            title = "Jak by měl držitel CCW Permitu komunikovat s policií, když nosí skrytou střelnou zbraň?",
            pointValue = 3,
            answers = {
                { "Střelnou zbraň schovejte a policistovi se o ní nezmiňujte." },
                { "Ukažte střelnou zbraň policistovi na znamení spolupráce." },
                { "Okamžitě informujte policistu o skryté střelné zbrani.", true },
            }
        },
        {
            title = "Lze v San Andreas v sebeobraně legálně střílet varovné výstřely?",
            pointValue = 2,
            answers = {
                { "Ano, varovné výstřely jsou povoleny k odvrácení hrozby." },
                { "Výstražné výstřely jsou povoleny, pokud se střílí do vzduchu." },
                { "Ne, varovné výstřely jsou zákonem zakázány.", true },
            }
        },
        {
            title = 'Jaký je v San Andreas požadavek "adekvátního důvodu" pro získání CCW Permitu?',
            pointValue = 2,
            answers = {
                { "Jednoduše vyjadřuje touhu po osobní ochraně." },
                { "Každý může legálně nosit svou legální střelnou zbraň podle druhého dodatku ústavy Spojených států." },
                { "Poskytnutí pádného důvodu, jako je například reálné ohrožení osobní bezpečnosti.", true },
            }
        },
        {
            title = "Jste v obchodě, když do něj vstoupí ozbrojená osoba, namíří na vás a prodavače zbraň a požaduje peníze z pokladny. Jste držitelem CCW Permitu a máte u sebe skrytou střelnou zbraň. Jaké kroky byste měli podniknout na základě kalifornských zákonů?",
            pointValue = 2,
            answers = {
                { "Vytáhněte střelnou zbraň a okamžitě na lupiče zaútočte, abyste ochránili sebe i prodavače." },
                { "Snažte se nenápadně opustit obchod, aniž byste na sebe upozornili." },
                { "Vyhovte požadavkům lupiče a vyvarujte se jakéhokoli jednání, které by mohlo situaci vyhrotit.", true },
            }
        },
        {
            title = "Jak správně nosit nabitou střelnou zbraň?",
            pointValue = 1,
            answers = {
                { "S prstem na spoušti pro rychlou reakci." },
                { "Namířením střelné zbraně na vlastní tělo pro lepší kontrolu." },
                { "Ve skrytém pouzdře, zajištěná a namířená bezpečným směrem.", true },
            }
        },
    },
    {
        {
            title = "Jsou držitelé CCW Permitu povinni informovat policisty o tom, že nosí skrytou střelnou zbraň?",
            pointValue = 3,
            answers = {
                { "Pouze pokud se policista výslovně ptá na střelné zbraně." },
                { "Ne, tyto informace není nutné sdělovat." },
                { "Ano, okamžitě při jakékoli interakci s policií.", true },
            }
        },
        {
            title = "Co by měl držitel CCW Permitu dělat po použití střelné zbraně v sebeobraně?",
            pointValue = 2,
            answers = {
                { "Okamžitě opusťte místo incidentu, abyste se vyhnuli právním komplikacím." },
                { "Střelnou zbraň schovejte a vyhněte se kontaktu s policií." },
                { "Nahlaste incident policií. ", true },
            }
        },
        {
            title = "Lze podle kalifornského práva považovat použití střelné zbraně k ochraně svého majetku, například auta, za oprávněnou sebeobranu?",
            pointValue = 2,
            answers = {
                { "Ano, máte právo chránit svůj majetek za každou cenu." },
                { "Pouze v případě, že se jedná o majetek značné peněžní hodnoty." },
                { "Ne, použití smrtící síly k ochraně majetku se obecně nepovažuje za ospravedlnitelnou sebeobranu.", true },
            }
        },
        {
            title = "Jak často musí držitel CCW Permitu v San Andreas obnovovat své povolení?",
            pointValue = 1,
            answers = {
                { "Každých 5 let." },
                { "Každých 10 let." },
                { "Neexistuje žádná povinnost obnovení.", true },
            }
        },
        {
            title = "Jste v obchodě, když do něj vstoupí ozbrojená osoba, namíří na vás a prodavače zbraň a požaduje peníze z pokladny. Jste držitelem CCW Permitu a máte u sebe skrytou střelnou zbraň. Jaké kroky byste měli podniknout na základě kalifornských zákonů?",
            pointValue = 2,
            answers = {
                { "Vytáhněte střelnou zbraň a okamžitě na lupiče zaútočte, abyste ochránili sebe i prodavače." },
                { "Snažte se nenápadně opustit obchod, aniž byste na sebe upozornili." },
                { "Vyhovte požadavkům lupiče a vyvarujte se jakéhokoli jednání, které by mohlo situaci vyhrotit.", true },
            }
        },
    },
    {
        {
            title = "Může vám policie zabavit střelnou zbraň, pokud jste odsouzený zločinec?",
            pointValue = 3,
            answers = {
                { "Ne, pokud jste střelnou zbraň získali legálně před odsouzením." },
                { "Ano, ale pouze pokud jsou střelné zbraně registrovány na vaše jméno." },
                { "Ano, odsouzení zločinci mají obecně zakázáno držet střelné zbraně.", true },
            }
        },
        {
            title = "Přijde k vám policista a požádá vás o předložení CCW Permitu a ID karty. Jaká je vhodná reakce?",
            pointValue = 3,
            answers = {
                { "Odmítněte poskytnout jakékoli informace, dokud se neporadíte se svým právníkem." },
                { "Požádejte policistu o zdůvodnění, proč si vyžádal vaše povolení." },
                { "Spolupracujte s policistou a předložte mu CCW Permit a ID/DL kartu.", true },
            }
        },
        {
            title = "Může vám policista při zadržení dočasne vzít zbraň?",
            pointValue = 2,
            answers = {
                { "Ne, ve většině případů vám policista při zadržení nemůže vzít zbraň bez příkazu k prohlídce." },
                { "Ne, policista vám při zadržení nemůže zabavit zbraň bez odůvodnění a dodržení zákonných postupů." },
                { "Ano, policista vám může při zadržení vzít zbraň, pokud se domnívá, že je to nezbytné pro jeho bezpečnost, bezpečnost ostatních nebo v rámci vyšetřování.", true },
            }
        },
        {
            title = "Je držitel CCW Permitu povinen odevzdat povolení policií, pokud mu bylo zabaveno?",
            pointValue = 1,
            answers = {
                { "Ne, policie nemůže odebírat CCW Permity." },
                { "Ano, do 5 dnů od zabavení." },
                { "Ano, do 2 dnů od zabavení.", true },
            }
        },
        {
            title = "Jak často musí držitel CCW Permitu v San Andreas obnovovat své povolení?",
            pointValue = 1,
            answers = {
                { "Každých 5 let." },
                { "Každých 10 let." },
                { "Neexistuje žádná povinnost obnovení.", true },
            }
        },
    },
}

RegisterNetEvent("strin_receptions:callOfficer", function()
    local _source = source
    local xPlayer = ESX.GetPlayerFromId(_source)
    if(not xPlayer) then
        return
    end

    if(RecentlyCalledOfficerTime) then
        local remainingSeconds = math.floor((RecentlyCalledOfficerTime + (5 * 60)) - os.time())
        if(remainingSeconds > 0) then
            xPlayer.showNotification(("Officer byl už nedávno vyžádán, vyčkejte %s sekund."):format(
                remainingSeconds
            ))
            return
        else
            RecentlyCalledOfficerTime = nil
        end
    end

    local distance = #(GetEntityCoords(GetPlayerPed(_source)) - RECEPTIONS["mrpd"].coords)
    if(distance > 10.0) then
        xPlayer.showNotification("Od recepce jste moc daleko!", { type = "error" })
        return
    end

    RecentlyCalledOfficerTime = os.time()
    local data = {
        displayCode = 'MRPD',
        description = "Vyžádání Officera",
        isImportant = 0,
        recipientList = LawEnforcementJobs, 
        length = '20000',
        infoM = 'fa-info-circle',
        info = xPlayer.get("fullname"),
    }
    local dispatchData = { dispatchData = data, caller = 'Fero', coords = RECEPTIONS["mrpd"].coords}
    TriggerEvent('wf-alerts:svNotify', dispatchData)
end)

RegisterNetEvent("strin_receptions:callSupervisor", function()
    local _source = source
    local xPlayer = ESX.GetPlayerFromId(_source)
    if(not xPlayer) then
        return
    end

    if(RecentlyCalledSupervisorTime) then
        local remainingSeconds = math.floor((RecentlyCalledSupervisorTime + (5 * 60)) - os.time())
        if(remainingSeconds > 0) then
            xPlayer.showNotification(("Supervisor byl už nedávno vyžádán, vyčkejte %s sekund."):format(
                remainingSeconds
            ))
            return
        else
            RecentlyCalledSupervisorTime = nil
        end
    end

    local distance = #(GetEntityCoords(GetPlayerPed(_source)) - RECEPTIONS["mrpd"].coords)
    if(distance > 10.0) then
        xPlayer.showNotification("Od recepce jste moc daleko!", { type = "error" })
        return
    end

    RecentlyCalledSupervisorTime = os.time()
    local data = {
        displayCode = 'MRPD',
        description = "Vyžádání Supervisora",
        isImportant = 0,
        recipientList = LawEnforcementJobs, 
        length = '20000',
        infoM = 'fa-info-circle',
        info = xPlayer.get("fullname"),
    }
    local dispatchData = { dispatchData = data, caller = 'Fero', coords = RECEPTIONS["mrpd"].coords}
    TriggerEvent('wf-alerts:svNotify', dispatchData)
end)

function GenerateTest()
    math.randomseed(GetGameTimer())
    local preset = lib.table.deepclone(CCW_TEST_PRESETS[math.random(1, #CCW_TEST_PRESETS)])
    for k,v in pairs(preset) do
        table.sort(v.answers, function(a,b)
            local totalLength = a[1]:len() + b[1]:len() + math.random(1,99)
            math.randomseed(GetGameTimer() + 100)
            local multipliedLength = a[1]:len() * b[1]:len() + math.random(1,99)
            return totalLength * multipliedLength > tonumber(tostring(totalLength * multipliedLength):reverse())
        end)
    end
    return preset
end

RegisterNetEvent("strin_receptions:requestCCWCard", function()
    local _source = source
    local xPlayer = ESX.GetPlayerFromId(_source)
    if(not xPlayer) then
        return
    end
    if(not exports.strin_licenses:CheckLicense(xPlayer.identifier, "ccw", xPlayer.get("char_id"))) then
        xPlayer.showNotification("Nemáte zaregistrované CCW povolení!", { type = "error" })
        return
    end
    if((xPlayer.getMoney() - 5000) < 0) then
        xPlayer.showNotification("Nemáte dostatek peněz!", { type = "error" })
        return
    end
    xPlayer.removeMoney(5000)
    local time = os.date("%d/%m/%Y")
    exports.ox_inventory:AddItem(_source, "ccw_permit", 1, {
        holder = xPlayer.get("fullname"),
        issuedOn = time,
    })
end)

RegisterNetEvent("strin_receptions:requestFSCCard", function()
    local _source = source
    local xPlayer = ESX.GetPlayerFromId(_source)
    if(not xPlayer) then
        return
    end
    if(not exports.strin_licenses:CheckLicense(xPlayer.identifier, "fsc", xPlayer.get("char_id"))) then
        xPlayer.showNotification("Nemáte zaregistrované FSC povolení!", { type = "error" })
        return
    end
    if((xPlayer.getMoney() - 5000) < 0) then
        xPlayer.showNotification("Nemáte dostatek peněz!", { type = "error" })
        return
    end
    xPlayer.removeMoney(5000)
    local time = os.date("%d/%m/%Y")
    exports.ox_inventory:AddItem(_source, "fsc_card", 1, {
        holder = xPlayer.get("fullname"),
        issuedOn = time,
    })
end)

lib.callback.register("strin_receptions:requestCCWTest", function(source)
    local _source = source
    local xPlayer = ESX.GetPlayerFromId(_source)
    if(not xPlayer) then
        return false, "Neexistující hráč!"
    end
    if(OngoingTests[_source]) then
        return false, "Již test probíhá!"
    end
    if(exports.strin_licenses:CheckLicense(xPlayer.identifier, "ccw", xPlayer.get("char_id"))) then
        return false, "Již CCW povolení máte!"
    end
    if((xPlayer.getMoney() - 10000) < 0) then
        return false, "Nedostatek peněz!"
    end
    xPlayer.removeMoney(10000)
    local test = GenerateTest()
    OngoingTests[_source] = test
    return test
end)

RegisterNetEvent("strin_receptions:validateCCWTest", function(answers)
    local _source = source
    local xPlayer = ESX.GetPlayerFromId(_source)
    if(not xPlayer) then
        return
    end
    if(not OngoingTests[_source]) then
        return
    end
    local test = OngoingTests[_source]
    local totalPoints = 0
    for k,v in pairs(answers) do
        if(test[k].answers[v][2] == true) then
            totalPoints += test[k].pointValue
        end
    end
    OngoingTests[_source] = nil
    if(totalPoints <= 6) then
        xPlayer.showNotification("Bohužel jste nesplnil/a test na dostatečné množství bodů, zkuste to příště.", {
            type = "error"
        })
        return
    end
    xPlayer.showNotification("Podařilo se Vám složit test na CCW!", { type = "success" })
    exports.strin_licenses:AddLicense(xPlayer.identifier, "ccw", xPlayer.get("char_id"))
end)

AddEventHandler("playerDropped", function()
    local _source = source
    if(OngoingTests[_source]) then
        OngoingTests[_source] = nil
    end
end)