$(async () => {
    const ResourceName = "strin_loadscreen";
    const HideElements = () => {
        $(`#container`).hide();
        $(`#video-container`).hide();
        $(`#center-title`).hide();
        $(`#left-title`).hide();
        $(`#right-title`).hide();  
    };

    const Wait = async (ms) => new Promise(res => setTimeout(res, ms))
    const Sections = [
        {
            label: "Management",
            content: ["Strin"].join("<br/>"),
            side: "right",
        },
        {
            label: "Administration",
            content: ["Nannie", "Kerb", "Seryozka", "iVolneck", "Tomix"].join("<br/>"),
            side: "left",
        },
        {
            label: "Art & Design",
            content: ["Strin", "Kerb", "Nannie"].join("<br/>"),
            side: "right",
        },
        {
            label: "Coding",
            content: ["Strin"].join("<br/>"),
            side: "left",
        },
        {
            label: "Cars",
            content: ["Nannie", "Kerb", "Midget"].join("<br/>"),
            side: "right",
        },
        {
            label: "Clothing",
            content: ["Nannie", "iVolneck"].join("<br/>"),
            side: "left",
        }
    ];
    let AudioContext = window.AudioContext || window.webkitAudioContext;
    const context = new AudioContext();
    const gainNode = context.createGain();
    const storage = JSON.parse(localStorage.getItem("STRIN_LOADSCREEN:DATA"));
    let watched = storage && storage.watched;
    let muteAudio = (storage && storage.mute) ? true : false; 
    let sourceNode = undefined;

    if(muteAudio) {
        $(`#volume-input`).prop("checked", muteAudio);
    } else {
        $(`#volume-input`).prop("checked", false);
    }

    const SetupAudioNodes = () => {
	    const analyser = context.createAnalyser();
        gainNode.gain.value = 0.25;
        gainNode.connect(context.destination);
	    sourceNode = context.createBufferSource();	
	    sourceNode.connect(analyser);
	    sourceNode.connect(gainNode);
    };

    const PlaySong = () => {
        sourceNode = null;
        SetupAudioNodes();
        
        const request = new XMLHttpRequest();
        
        request.open('GET', './song.ogg', true);
        request.responseType = 'arraybuffer';
    
        request.onload = () => {
            
            context.decodeAudioData(request.response, (buffer) => {
                sourceNode.buffer = buffer;
                sourceNode.start(0);
            });
        };
        request.send();
    };

    window.addEventListener("keydown", (e) => {
        if(e.key == " " || e.key == "Spacebar") {
            const isChecked = $(`#volume-input`).prop("checked");
            muteAudio = !isChecked;
            
            localStorage.setItem("STRIN_LOADSCREEN:DATA", JSON.stringify({
                    watched,
                    mute: muteAudio
            }));
            if(muteAudio) {
                if((sourceNode != undefined && sourceNode != null))
                    sourceNode.stop(0)
            } else {
                PlaySong()
            }
            $(`#volume-input`).prop("checked", muteAudio);
        }
    });

    HideElements();

    setTimeout(() => {
        if(!muteAudio)
            PlaySong();
    }, 1000)

    const StartAnimation = async () => {
        $(`#container`).show();
        $(`#video-container`).show();
        $(`#left-title`).show();
        $(`#right-title`).show();
        const centerTitle = $(`#center-title`);
        const startTextAnimations = async () => {
            for(let i=0; i < Sections.length; i++) {
                const {side, label, content} = Sections[i];
                $(`#${side}-head-title`).text(label);
                $(`#${side}-bottom-title`).html(content);
                $(`#${side}-head-title`).fadeIn(1500);
                $(`#${side}-bottom-title`).fadeIn(1500, async () => {
                    await Wait(4000);
                    $(`#${side}-head-title`).fadeOut(1500);
                    $(`#${side}-bottom-title`).fadeOut(1500);
                });

                await Wait(7000);

                if((Sections.length - 1) == i) {
                    if(!(storage && storage.watched)) 
                        localStorage.setItem("STRIN_LOADSCREEN:DATA", JSON.stringify({
                             watched: true,
                             mute: muteAudio
                        }));
                    
                    startTextAnimations();
                    watched = true;
                    fetch(`https://${ResourceName}/status`, {
                        method: "POST",
                        body: watched
                    });           
                }
            }
        };
        centerTitle.fadeIn(5000, async () => {
            await startTextAnimations()
        });
    };

    window.addEventListener("message", (e) =>{
        const {action} = e.data;
        if(action == "resourceReady") {
            fetch(`https://${ResourceName}/status`, {
                method: "POST",
                body: watched
            });
        } else if(action == "hideLoadingScreen") {
            HideElements();
        }
    });
    
    StartAnimation();
});