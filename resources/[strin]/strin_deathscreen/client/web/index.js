window.onload = () => {
    let DeathscreenInterval = null;
    const body = document.getElementsByTagName("body")[0];
    const distress = document.getElementById("deathscreen-distress");
    const control = document.getElementById("deathscreen-control");

    const ShowDeathscreen = (time) => {
        body.style.display = "flex";
        ShowDistress();
        /*let timer = document.getElementById("deathscreen-timer");
        timer.textContent = time;*/
        DeathscreenInterval = setInterval(() => {
            time--;
            if(time <= 0) {
                clearInterval(DeathscreenInterval);
                control.innerHTML = '<br/>Držte <span class="deathscreen-colored-text">[E]</span> pro respawn.'
                return;
            }
            //timer.textContent = time;
        }, 1000);
    };

    const ShowDistress = () => {
        //distress.innerHTML = 'Stiskni <span class="deathscreen-colored-text">[G] (nebo jiné)</span> pro tísňové volání,';
        distress.innerHTML = '<br/>Stiskni <span class="deathscreen-colored-text">[G]</span> pro tísňové volání.';
        //control.innerHTML = 'respawn možný za <span id="deathscreen-timer" class="deathscreen-colored-text">937</span> sekund.';
    };

    const ChangeDistress = () => {
        distress.innerHTML = '<span class="deathscreen-colored-text">Pomoc zavolána.</span>';
    };

    const HideDistress = () => {
        distress.innerHTML = "";
        control.innerHTML = "";
    };
    
    
    const HideDeathscreen = () => {
        clearInterval(DeathscreenInterval);
        DeathscreenInterval = null;
        body.style.display = "none";
        HideDistress();
    };

    //ShowDeathscreen(1);
    window.addEventListener("message", (e) => {
        const {action, time, lockDistress} = e.data;
        if(action == "show") {
            ShowDeathscreen(time);
        } else if (action == "hide") {
            HideDeathscreen();
        } else if (action == "distress") {
            if(lockDistress) {
                ChangeDistress();
            } else {
                ShowDistress();
            }
        }
    });
}