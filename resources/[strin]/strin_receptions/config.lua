RECEPTIONS = {
    ["mrpd"] = {
        --label = "Los Santos Police Department",
        coords = vector3(439.86895751953, -978.85260009766, 30.68932723999),
        heading = 114.79,
        model = `s_m_y_cop_01`,
        distance = 3.25,
        options = {
            {
                label = "Přivolat Officera",
                icon = "fa-solid fa-phone-volume",
                serverEvent = "strin_receptions:callOfficer",
            },
            {
                label = "Podat stížnost",
                icon = "fa-solid fa-file-circle-exclamation",
                event = "strin_receptions:fileComplain",
            },
            {
                label = "Nahlásit zločin",
                icon = "fa-solid fa-gun",
                event = "strin_receptions:reportCrime",
            },
            {
                label = "CCW Permit / FSC Karta",
                icon = "fa-solid fa-id-card",
                event = "strin_receptions:openPermitsMenu",
            },
            {
                label = "Vyžádání FSC",
                icon = "fa-solid fa-clipboard-list",
                serverEvent = "strin_receptions:requestFSCPermit", 
            },
            {
                label = "Veřejná LSPD aplikace",
                icon = "fa-brands fa-app-store-ios",
                event = "strin_receptions:copyLSPDDiscord",
            },
        },
    }
}