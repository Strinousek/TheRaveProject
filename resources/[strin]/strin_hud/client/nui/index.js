$(() => {
    const backgroundElems = ["#option-container"];
    const bars = ["#health-progress", "#armor-progress", "#energy-progress", "#breath-progress"]
    const backgroundClass = [".info-icon", ".info-bar"];
    let madeDraggables = false;
    let elems = [
        {
            elem: "#player-container", 
            id: "player",
        },
        {
            elem: "#option-container", 
            id: "option",
        },
        {
            elem: "#vehicle-container", 
            id: "vehicle",
        },
        {
            elem: "#street-container", 
            id: "street",
        },
    ];

    const defaultSettings = {
        //enableEnergy: true,
        backgroundColor: "rgba(44, 62, 80,0.6)",
        border: false,
        alwaysDisplay: true,
        borderColor: "black",
        stackBars: false,
        showStreets: false,
        healthColor: "rgba(46, 204, 113,1.0)",
        armorColor: "rgba(52, 152, 219,1.0)",
        staminaColor: "#f1c40f",
        breathColor: "rgb(154, 192, 218)",
    };

    let currentSettings = {...defaultSettings};

    const stor = {
        get: (name) => {
            return localStorage.getItem(`shud:${name}`)
        },
        set: (name, val) => {
            localStorage.setItem(`shud:${name}`, val)
        },
        checkForDrags: () => {
            for(let i=0; i < elems.length; i++) {
                let top = stor.get(`${elems[i].id}Top`);
                let left = stor.get(`${elems[i].id}Left`);
                if(top != null) {
                    $(elems[i].elem).css("top", top);
                };
                if(left != null) {
                    $(elems[i].elem).css("left", left);
                };
            };
        },
        updateSettings: () => {
            localStorage.setItem(`shud:options`, JSON.stringify(currentSettings))
        },
    };

    const setDefaultPositions = () => {
        for(let i=0; i < elems.length; i++) {
            if(elems[i].dTop == undefined && elems[i].dLeft == undefined) {
                elems[i].dTop = $(elems[i].elem).css("top");
                elems[i].dLeft = $(elems[i].elem).css("left");
            } else {
                $(elems[i].elem).css("top", elems[i].dTop);
                $(elems[i].elem).css("left", elems[i].dLeft);
            }
        };
    };

    setDefaultPositions();

    const setColorInputValues = () => {
        $("#color-input").val(currentSettings.backgroundColor);
        $("#border-color-input").val(currentSettings.borderColor);
        $("#health-color-input").val(currentSettings.healthColor);
        $("#armor-color-input").val(currentSettings.armorColor);
        $("#stamina-color-input").val(currentSettings.staminaColor);
        $("#breath-color-input").val(currentSettings.breathColor);
    };

    const loadSettings = () => {
        let settings = stor.get("options")
        if(settings != undefined) {
            currentSettings = JSON.parse(settings);
            setColorInputValues();
            if(currentSettings.enableEnergy != true) {
                $("#stamina-input").prop('checked', false);
                $("#energy-info").fadeOut();
            };
            if(currentSettings.border == true) {
                $("#border-input").prop('checked', true);
            };
            if(currentSettings.stackBars == false) {
                $("#stack-input").prop('checked', false);
                $("#player-main").css("display", "flex")
            };
            if(currentSettings.showStreets == true) {
                $("#street-input").prop('checked', true);
            };
            if(currentSettings.alwaysDisplay == true) {
                $("#display-input").prop('checked', true);
            }
            setBackgroundColors();
        } else {
            setColorInputValues();
        }
    };

    const setBackgroundColors = () => {
        for(let i=0; i < bars.length; i++) {
            if(bars[i].includes("health")) {
                $(bars[i]).css("background-color", currentSettings.healthColor)
            } else if(bars[i].includes("armor")) {
                $(bars[i]).css("background-color", currentSettings.armorColor)
            } else if(bars[i].includes("energy")) {
                $(bars[i]).css("background-color", currentSettings.staminaColor)
            } else if(bars[i].includes("breath")) {
                $(bars[i]).css("background-color", currentSettings.breathColor)
            };
        };
        for(let i=0; i < backgroundElems.length; i++) {
            $(backgroundElems[i]).css("background-color", currentSettings.backgroundColor);
            if(currentSettings.border) {
                $(backgroundElems[i]).css("border", `1px solid ${currentSettings.borderColor}`);
            } else {
                $(backgroundElems[i]).css("border", "none");
            };
        };
        for(let i=0; i < backgroundClass.length; i++) {
            $(backgroundClass[i]).css("background-color", currentSettings.backgroundColor);
            if(currentSettings.border) {
                $(backgroundClass[i]).css("border", `1px solid ${currentSettings.borderColor}`);
            } else {
                $(backgroundClass[i]).css("border", "none");
            };
        };
    };

    loadSettings();

    stor.checkForDrags();
    
    const setPercentage = (type, val) => {
        $(`#${type}-progress`).css("width", `${val}%`)
    };

    const openHud = () => {
        $("#container").fadeIn();
    };

    const closeHud = () => {
        $("#container").fadeOut();
    };

    const updateData = (data) => {
        setPercentage("health", data.health - 100);
        setPercentage("armor", data.armor);
        setPercentage("energy", data.energy);
        if(currentSettings.alwaysDisplay) {
            $("#health-info").show();
            $("#armor-info").show();
            $("#energy-info").show();
        } else {
            if((data.health - 100) < data.maxHealth - 100) {
                $("#health-info").fadeIn();
            } else {
                $("#health-info").fadeOut();
            }
            if(data.armor > 0) {
                $("#armor-info").fadeIn();
            } else {
                $("#armor-info").fadeOut();
            }
            if(data.energy < 100) {
                $("#energy-info").fadeIn();
            } else {
                $("#energy-info").fadeOut();
            }
        }
        if(data.isUnderwater == true) {
            setPercentage("breath", Math.floor(data.breath * 10));
            $("#breath-info").fadeIn();
        } else {
            $("#breath-info").fadeOut();
        }
        if(data.inVehicle == true) {
            $("#vehicle-container").show();
            $("#fuel").text(data.fuel);
            $("#speed").text(data.speed);
            if(data.hasSeatbelt == true) {
                $("#seatbelt").html(`<i class="fas fa-bell"></i>`);
                $("#seatbelt").css("color", "#2ecc71");
            } else {
                $("#seatbelt").html(`<i class="fas fa-bell-slash"></i>`);
                $("#seatbelt").css("color", "#e74c3c");
            };
            if(currentSettings.showStreets) {
                $("#street-container").show();
                if(data.street2 != "" && data.street2 != undefined) {
                    $("#street-container").text(`${data.street1} | ${data.street2} | ${data.zone}`);
                } else {
                    $("#street-container").text(`${data.street1} | ${data.zone}`);
                }
            } else {
                $("#street-container").hide();
            }
        } else {
            $("#street-container").hide();
            $("#vehicle-container").hide();
        }

        const minimapWidthInPixels = Math.floor(window.screen.width * data.minimapWidth)
        //console.log(minimapWidthInPixels / 3)
        $(".info-bar").css("width", `${minimapWidthInPixels / 3.25}px`)
    };

    $("#color-input").change(() => {
        currentSettings.backgroundColor = $("#color-input").val();
        setBackgroundColors();
        stor.updateSettings();
    });

    $("#stamina-input").change((e) => {
        let isChecked = $("#stamina-input").is(":checked");
        if(isChecked) {
            currentSettings.enableEnergy = true;
            $("#energy-info").fadeIn();
        } else if(!isChecked) {
            currentSettings.enableEnergy = false;
            $("#energy-info").fadeOut();
        }
        stor.updateSettings();
    });

    $("#stack-input").change((e) => {
        let isChecked = $("#stack-input").is(":checked");
        if(isChecked) {
            currentSettings.stackBars = true;
            $("#player-main").css("display", "block");
        } else if(!isChecked) {
            currentSettings.stackBars = false;
            $("#player-main").css("display", "flex");
        }
        stor.updateSettings();
    });

    $("#display-input").change((e) => {
        let isChecked = $("#display-input").is(":checked");
        if(isChecked) {
            currentSettings.alwaysDisplay = true;
        } else if(!isChecked) {
            currentSettings.alwaysDisplay = false;
        }
        stor.updateSettings();
    });

    $("#street-input").change((e) => {
        let isChecked = $("#street-input").is(":checked");
        if(isChecked) {
            currentSettings.showStreets = true;
        } else if(!isChecked) {
            currentSettings.showStreets = false;
        }
        stor.updateSettings();
    });

    $("#border-input").change((e) => {
        let isChecked = $("#border-input").is(":checked");
        if(isChecked) {
            currentSettings.border = true;
            setBackgroundColors();
        } else if(!isChecked) {
            currentSettings.border = false;
            setBackgroundColors();
        };
        stor.updateSettings();
    });

    $("#border-color-input").change(() => {
        currentSettings.borderColor = $("#border-color-input").val();
        setBackgroundColors();
        stor.updateSettings();
    });

    $("#health-color-input").change(() => {
        currentSettings.healthColor = $("#health-color-input").val();
        setBackgroundColors();
        stor.updateSettings();
    });

    $("#armor-color-input").change(() => {
        currentSettings.armorColor = $("#armor-color-input").val();
        setBackgroundColors();
        stor.updateSettings();
    });

    $("#stamina-color-input").change(() => {
        currentSettings.staminaColor = $("#stamina-color-input").val();
        setBackgroundColors();
        stor.updateSettings();
    });

    $("#breath-color-input").change(() => {
        currentSettings.breathColor = $("#breath-color-input").val();
        setBackgroundColors();
        stor.updateSettings();
    });

    const storeSettings = () => {
        stor.updateSettings();
        for(let i=0; i < elems.length; i++) {
            let elem = $(elems[i].elem)
            let newTop = elem.css("top");
            let newLeft = elem.css("left");
            stor.set(`${elems[i].id}Top`, newTop);
            stor.set(`${elems[i].id}Left`, newLeft);
        };
    };

    $("#reset-input").on('click', () => {
        currentSettings = {...defaultSettings};
        $("#energy-info").fadeIn();
        $("#stamina-input").prop("checked", true);
        $("#stack-input").prop("checked", true);
        $("#border-input").prop("checked", false);
        $("#street-input").prop("checked", false);
        $("#player-main").css("display", "block");
        setColorInputValues();
        setBackgroundColors();
        setDefaultPositions();
        storeSettings();
    });

    
    $("#exitEdit").on("click", () => {
        storeSettings();
        $("#option-container").fadeOut();
        $.post("https://strin_hud/exitEdit", JSON.stringify({}));
    });
    
    const editHud = () => {
        $("#option-container").fadeIn();
        if(!madeDraggables) {
            for(let i=0; i < elems.length; i++) {
                let elem = $(elems[i].elem)
                elem.draggable({
                    scroll: false,
                    containment: "body",
                    stop: () => {
                        let newTop = elem.css("top");
                        let newLeft = elem.css("left");
                        stor.set(`${elems[i].id}Top`, newTop);
                        stor.set(`${elems[i].id}Left`, newLeft);
                    },
                });
            };
            madeDraggables = true
        };
    };
    
    document.onkeyup = (data) => {
        if (data.which == 27) {
            storeSettings();
            $("#option-container").fadeOut();
            $.post("https://strin_hud/exitEdit", JSON.stringify({}));
            return;
        };
    };

    const updateSeatbelt = (data) => {
        if(data.hasSeatbelt == true) {
            $("#seatbelt").html(`<i class="fas fa-bell"></i>`);
            $("#seatbelt").css("color", "#2ecc71");
        } else {
            $("#seatbelt").html(`<i class="fas fa-bell-slash"></i>`);
            $("#seatbelt").css("color", "#e74c3c");
        };
    };

    window.addEventListener("message", (e) => {
        let data = e.data
        if(data.action == "openHud") {
            openHud()
        } else if (data.action == "updateData") {
            updateData(data)
        } else if (data.action == "closeHud") {
            closeHud()
        } else if (data.action == "editHud") {
            editHud()
        } else if (data.action == "updateSeatbelt") {
            updateSeatbelt(data);
        }
    });
})