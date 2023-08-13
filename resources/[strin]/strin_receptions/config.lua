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
                serverEvent = "strin_receptions:callOfficer",
            },
            {
                label = "Podat stížnost",
                event = "strin_receptions:fileComplain",
            },
            {
                label = "Nahlásit zločin",
                event = "strin_receptions:reportCrime",
            },
            {
                label = "CCW Permit / FSC Karta",
                event = "strin_receptions:openPermitsMenu",
            },
            {
                label = "Vyžádání FSC",
                serverEvent = "strin_receptions:requestFSCPermit", 
            },
            {
                label = "Veřejná LSPD aplikace",
                event = "strin_receptions:copyLSPDDiscord",
            },
        },
    }
}