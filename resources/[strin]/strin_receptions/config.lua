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
                label = "CCW Permit",
                event = "strin_receptions:requestCCWPermitTest",
            },
            {
                label = "FSC Permit",
                event = "strin_receptions:requestFSCPermit",
            },
            {
                label = "Veřejná LSPD aplikace",
                serverEvent = "strin_receptions:copyLSPDDiscord",
            },
        },
    }
}