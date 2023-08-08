$(() => {
    let players = [];
    let pageNum = 1;
    let pageSize = 32;
    let transition = false;

    const AddPlayerIntoScoreboard = (columnId, player) => {
        $(`#players-column-${columnId}`).append(`
            <div class="player">
                ${player.name}<span class="player-id">${player.id}</span>
            </div>
        `);
    };

    const CreateScoreboard = (receivedPlayers) => {
        $(`#container`).html(``);
        transition = true;
        if(typeof(receivedPlayers) == "object") {
            players = Object.values(receivedPlayers).filter(player => player != null);
        } else if(typeof(receivedPlayers) == "array") {
            players = receivedPlayers.filter(player => player != null);
        }
        $(`#container`).append(`
            <div class="players-container" id="players-page-${pageNum}">
                <div class="players-column" id="players-column-1">
                </div>
                <div class="players-column" id="players-column-2">
                </div>
                <div class="players-column" id="players-column-3">
                </div>
                <div class="players-column" id="players-column-4">
                </div>
            </div>
        `);

        const playerStartId = pageNum > 1 ? (pageNum - 1) * pageSize : 0;
        const playerEndId = pageNum > 1 ? ((pageNum * pageSize) + pageSize) : pageSize;
        let playersToDisplay = [];
        for(let i=playerStartId; i < playerEndId; i++) {
            if(players[i] != null)
                playersToDisplay.push(players[i]);
        }
        playersToDisplay = playersToDisplay.sort((a,b) => a.id-b.id);
        const playersPerColumn = Math.ceil(playersToDisplay.length / 4);
        let currentColumn = 1;
        for(let i=1; i <= playersToDisplay.length; i++) {
            const playerId = i;
            AddPlayerIntoScoreboard(currentColumn, playersToDisplay[playerId - 1])
            if(i % playersPerColumn == 0) 
                currentColumn++;
        }
        $("#wrapper").fadeIn(500, () => {
            transition = false;
        })
    };

    const SwitchPages = (side) => {
        const pageCount = players.length / pageSize
        if(pageCount < 1 || transition == true) {
            return
        }
        if(side == "LEFT") {
            if(pageNum <= 1)
                return;
            pageNum--;
        }
        if(side == "RIGHT") {
            if(pageNum >= pageCount)
                return;
            pageNum++;
        }

        CreateScoreboard();
    };

    /*
    window.addEventListener("keydown", (e) => {
        if(e.key == "a") 
            SwitchPages("LEFT");
        if(e.key == "d") 
            SwitchPages("RIGHT");
    });

    const GenerateRandomName = (length) => {
        let result = '';
        const characters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
        const charactersLength = characters.length;
        let counter = 0;
        while (counter < length) {
          result += characters.charAt(Math.floor(Math.random() * charactersLength));
          counter += 1;
        }
        return result;
    };

    const MakeTestPlayers = () => {
        let testPlayers = [];
        for(i=1; i < 5; i++) {
            const randomNum = Math.floor(1 + Math.random() * 20);
            testPlayers.push({name: GenerateRandomName(randomNum), id: Math.floor(1 + Math.random() * 64)});
        }
        return testPlayers
    };

    let testPlayers = MakeTestPlayers()
    CreateScoreboard(testPlayers);
    */

    window.addEventListener("message", (event) => {
        let {action, players, side} = event.data;
        if(action == "showScoreboard") {
            CreateScoreboard(players);
        } else if(action == "hideScoreboard"){
            transition = true;
            $("#wrapper").fadeOut(500, () => {
                transition = false;
            })
        } else if(action == "switch") {
            SwitchPages(side);
        };
    });
})