$(() => {
    let moving = false;
    let lastOffsetX = 0;
    let lastOffsetY = 0;
    let lastScreenX = 0.5 * screen.width;
    let lastScreenY = 0.5 * screen.height;
    let focusedPart = null;

    let clotheParts = [
        "tshirt", "torso", "decals",
        "arms", "pants", "shoes", 
        "chain", "bags", 
    ]

    const PostChange = (name, val) => {
        fetch(`https://strin_skin/changeSkinPart`, {
            method: "POST",
            body: JSON.stringify({
                part: name,
                value: val,
            })
        });
    };

    const ChangeSkinPart = (skinPartName) => {
        const newVal = $(`#skin-part-value-${skinPartName}`).val();
        PostChange(skinPartName, newVal);
    };

    const SetupSkinPartClicks = (skinPart, isClothe) => {
        if(isClothe) {
            $(`#skin-part-inputs-${skinPart.name}`).on("click", () => {
                if(skinPart != skinPart.name) 
                    FocusPart(skinPart.name, isClothe);
            });
        } else {
            $(`#skin-part-${skinPart.name}`).on("click", () => {
                if(focusedPart != skinPart.name) 
                    FocusPart(skinPart.name, isClothe);
            });
        }

        $(`#increment-${skinPart.name}`).on("click", () => IncrementSkinPart(skinPart.name));
        $(`#decrement-${skinPart.name}`).on("click", () => DecrementSkinPart(skinPart.name));

        $(`#skin-part-value-${skinPart.name}`).val(skinPart.value);

        $(`#skin-part-value-${skinPart.name}`).change(() => {
            FocusPart(skinPart.name);
            const elem = $(`#skin-part-value-${skinPart.name}`);
            const elemValue = elem.val();
            if(elemValue === "" || elemValue === undefined || elemValue === null || elemValue < skinPart.min) {
                elem.val(skinPart.min);
                ChangeSkinPart(skinPart.name);
            } else if(elemValue > skinPart.max) {
                elem.val(skinPart.max);
                ChangeSkinPart(skinPart.name);
            } else {
                ChangeSkinPart(skinPart.name);
            }
        });
    }

    const ShowMenu = (skinParts) => {
        skinParts.forEach((v,i) => {
            const pureName = v.name == "arms" ? v.name : v.name.replace("_1", "").replace("_2", "");
            const isClothe = clotheParts.includes(pureName);
            const variation = isClothe ? skinParts.find(o => o.name == `${pureName}_2`) : null;
            if(v.name.includes("_2") && isClothe)
                return;

            $("#menu-skin-parts-container").append(`<div key="${i}" id="skin-part-${isClothe ? pureName : v.name}" class="skin-part">
                <div class="skin-part-label">${v.label}</div>
                ${!isClothe ? `<div id="skin-part-inputs-${v.name}" class="menu-skin-parts-input-container">
                    <i id="decrement-${v.name}" class="skin-part-button fas fa-caret-left"></i>
                    <input id="skin-part-value-${v.name}" type="number" min="${v.min}" max="${v.max}" class="skin-part-value"></input>
                    <i id="increment-${v.name}" class="skin-part-button fas fa-caret-right"></i>
                </div>` : `<div id="skin-part-inputs-${pureName != "arms" ? pureName : "armsxd" }" class="menu-skin-parts-input-container">
                    <div id="skin-part-inputs-${v.name}" class="menu-skin-parts-input-container">
                        <i id="decrement-${v.name}" class="skin-part-button fas fa-caret-left"></i>
                        <input id="skin-part-value-${v.name}" type="number" min="${v.min}" max="${v.max}" class="skin-part-value"></input>
                        <i id="increment-${v.name}" class="skin-part-button fas fa-caret-right"></i>
                    </div>
                    <div id="skin-part-inputs-${variation.name}" class="menu-skin-parts-input-container">
                        <i id="decrement-${variation.name}" class="skin-part-button fas fa-caret-left"></i>
                            <input id="skin-part-value-${variation.name}" type="number" min="${variation.min}" max="${variation.max}" class="skin-part-value"></input>
                        <i id="increment-${variation.name}" class="skin-part-button fas fa-caret-right"></i>
                    </div>
                </div>`}
            </div>`);
      
            SetupSkinPartClicks(v, isClothe);
            if(isClothe) 
                SetupSkinPartClicks(variation, isClothe);
        });
        const pureName = skinParts[0].name == "arms" ? skinParts[0].name : skinParts[0].name.replace("_1", "").replace("_2", "")
        FocusPart(skinParts[0].name, clotheParts.includes(pureName));
        $("#menu-container").css("display", "flex")
        $("#camera-view").css("display", "block")
    };

    const IncrementSkinPart = (partName) => {
        const elem = $(`#skin-part-value-${partName}`);
        const elemValue = parseInt(elem.val()) + 1;
        const max = parseInt(elem.prop("max"));

        if(elemValue === "" || elemValue === undefined || elemValue === null || elemValue >= max) {
            elem.val(max);
            ChangeSkinPart(partName);
        } else if(elemValue <= max) {
            elem.val(elemValue);
            ChangeSkinPart(partName);
        }
    };

    const DecrementSkinPart = (partName) => {
        const elem = $(`#skin-part-value-${partName}`);
        const elemValue = parseInt(elem.val()) - 1;
        const min = parseInt(elem.prop("min"));

        if(elemValue === "" || elemValue === undefined || elemValue === null || elemValue < min) {
            elem.val(min);
            ChangeSkinPart(partName);
        } else if(elemValue >= min) {
            elem.val(elemValue);
            ChangeSkinPart(partName);
        }
    };
    
    const FocusPart = (skinPart, isClothe) => {
        $(`.skin-part-focused`).removeClass("skin-part-focused");
        $(`#skin-part-inputs-${skinPart}`).addClass("skin-part-focused");
        /*if(!isClothe) {
            $(`#skin-part-${skinPart}`)[0]?.scrollIntoView();
        } else {
            const pureName = skinPart.replace("_1", "").replace("_2", "")
            $(`#skin-part-${pureName}`)[0]?.scrollIntoView();
        }*/
        focusedPart = skinPart;
    };

    let isTimedOut = false
    window.addEventListener("keydown", (e) => {
        if(focusedPart && !isTimedOut) {
            if(e.key == "a") {
                DecrementSkinPart(focusedPart)
                isTimedOut = true
                setTimeout(() => {
                    isTimedOut = false
                }, 250);
            } else if(e.key == "d") {
                IncrementSkinPart(focusedPart)
                isTimedOut = true
                setTimeout(() => {
                    isTimedOut = false
                }, 250);
            } else if(e.key == "w") {

                const pureName = focusedPart == "arms" ? focusedPart : focusedPart.replace("_1", "").replace("_2", "");
                const isClothe = clotheParts.includes(pureName);
                if(!isClothe) {
                    const previousPart = $(`#skin-part-${focusedPart}`).prev();
                    if(previousPart && previousPart[0]) {
                        const previousPartName = previousPart[0].id.replace("skin-part-", "");
                        const isPreviousPartClothe = clotheParts.includes(previousPartName);
                        if(isPreviousPartClothe) {
                            FocusPart(`${previousPartName}_2`, isClothe);
                            return
                        }
                        FocusPart(previousPartName, isClothe);
                    }
                } else {
                    if(focusedPart.includes("_2")) {
                        const previousPart = $(`#skin-part-inputs-${focusedPart}`).prev();
                        if(previousPart && previousPart[0]) {
                            const previousPartName = previousPart[0].id.replace("skin-part-inputs-", "");
                            FocusPart(previousPartName, isClothe);
                        }
                        return;
                    }

                    const previousPart = $(`#skin-part-${pureName}`).prev();
                    if(previousPart && previousPart[0]) {
                        const previousPartName = previousPart[0].id.replace("skin-part-", "");
                        const isPreviousPartClothe = clotheParts.includes(previousPartName);
                        if(isPreviousPartClothe) {
                            FocusPart(`${previousPartName}_2`, isClothe);
                            return
                        }
                        FocusPart(previousPartName, isClothe);
                    }
                }
            } else if(e.key == "s") {
                const pureName = focusedPart == "arms" ? focusedPart : focusedPart.replace("_1", "").replace("_2", "");
                const isClothe = clotheParts.includes(pureName);
                if(!isClothe) {
                    const nextPart = $(`#skin-part-${focusedPart}`).next();
                    if(nextPart && nextPart[0]) {
                        const nextPartName = nextPart[0].id.replace("skin-part-", "");
                        const isNextPartClothe = clotheParts.includes(nextPartName);
                        if(isNextPartClothe) {
                            FocusPart(nextPartName != "arms" ? `${nextPartName}_1` : nextPartName, isClothe);
                            return
                        }
                        FocusPart(nextPartName, isClothe);
                    }
                } else {
                    if(focusedPart.includes("_1") || focusedPart == "arms") {
                        const nextPart = $(`#skin-part-inputs-${focusedPart}`).next();
                        if(nextPart && nextPart[0]) {
                            const nextPartName = nextPart[0].id.replace("skin-part-inputs-", "");
                            FocusPart(nextPartName, isClothe);
                        }
                        return;
                    }
                    const nextPart = $(`#skin-part-${pureName}`).next();
                    if(nextPart && nextPart[0]) {
                        let nextPartName = nextPart[0].id.replace("skin-part-", "");
                        const isNextPartClothe = clotheParts.includes(nextPartName);
                        if(isNextPartClothe) {
                            FocusPart(nextPartName != "arms" ? `${nextPartName}_1` : nextPartName, isClothe);
                            return
                        }
                        FocusPart(nextPartName, isClothe);
                    }
                }
            }
        }
    });

    const UpdateSkinPart = (partName, partMin, partMax) => {
        const valueElem = $(`#skin-part-value-${partName}`);
        valueElem.prop("min", partMin);
        valueElem.val(partMin);
        valueElem.prop("max", partMax);
        ChangeSkinPart(partName);
    };

    const HideMenu = () => {
        focusedPart = null;
        $("#menu-container").css("display", "none");
        $("#camera-view").css("display", "none")
        $("#menu-skin-parts-container").html("");
    };

    $(".menu-view-button").on('click', (e) => {
        const view = e.currentTarget.id.replace("menu-", "");
        fetch(`https://strin_skin/setCameraView`, {
            method: "POST",
            body: JSON.stringify({
                view,
            })
        });
    });

    $('#camera-view').on('mousedown', (e) => {
        if (e.button == 0)
            moving = true;
    });

    $('#camera-view').on('mouseup', (e) => {
        if (moving && e.button == 0) 
            moving = false;
    });

    $('#camera-view').on('mousemove', (e) => {
        if(!moving) 
            return;

        let offsetX = e.screenX - lastScreenX;
        let offsetY = e.screenY - lastScreenY;
        if ((lastOffsetX > 0 && offsetX < 0) || (lastOffsetX < 0 && offsetX > 0)) {
            offsetX = 0
        }
        if ((lastOffsetY > 0 && offsetY < 0) || (lastOffsetY < 0 && offsetY > 0)) {
            offsetY = 0
        }
        lastScreenX = e.screenX;
        lastScreenY = e.screenY;
        lastOffsetX = offsetX;
        lastOffsetY = offsetY;
        
        fetch(`https://strin_skin/updateCameraRotation`, {
            method: "POST",
            body: JSON.stringify({
                x: offsetX,
                y: offsetY,
            })
        });
    });

    $('#camera-view').on('wheel', (e) => {
        const zoom = e.originalEvent.deltaY / 2000;
        fetch(`https://strin_skin/updateCameraZoom`, {
            method: "POST",
            body: JSON.stringify({
                zoom
            })
        });
    });

    $("#menu-cancel").on('click', () => {
        fetch(`https://strin_skin/cancelMenu`, {
            method: "POST",
            body: JSON.stringify({})
        });
    });

    $("#menu-confirm").on('click', () => {
        fetch(`https://strin_skin/confirmMenu`, {
            method: "POST",
            body: JSON.stringify({})
        });
    });

    document.onkeyup = (data) => {
        if (data.key == "Escape") {
            HideMenu();
            fetch(`https://strin_skin/cancelMenu`, {
                method: "POST",
                body: JSON.stringify({})
            });
            return;
        };
    };

    /*ShowMenu([
        {
            name: "torso_1",
            label: "Bundy 1",
            min: 0,
            value: 2,
            max: 10
        },
        {
            name: "torso_2",
            label: "Bundy 2",
            min: 0,
            value: 2,
            max: 10
        },
        {
            name: "arms",
            label: "Rukavice",
            min: -10,
            value: 2,
            max: 10
        },
        {
            name: "arms_2",
            label: "Rukavice 2",
            min: -10,
            value: 2,
            max: 10
        }
    ]);*/

    window.addEventListener("message", (e) => {
        let data = e.data;
        if(data.action == "showMenu") {
            ShowMenu(data.parts);
        } else if(data.action == "hideMenu") {
            HideMenu()
        } else if(data.action == "updateSkinPart") {
            UpdateSkinPart(data.part, data.min, data.max);
        };
    });
})