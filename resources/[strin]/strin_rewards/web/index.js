window.onload = () => {
    const Board = document.getElementById("board");
    const BoardHeaderTimerDisplayer = document.getElementById("board-header-time-displayer");
    const BoardRewards = document.getElementById("board-rewards");
    const ResourceName = "strin_rewards";
    const ListenedExitKeys = ["Escape", "Backspace"];
    let PlayedTimeInterval = null;

    const UseFetch = async (endpoint, method, body) => {
        const fetchData = { method: method };
        if(method != "GET")
            fetchData.body = JSON.stringify(body ?? {});
        return await fetch(`https://${ResourceName}/${endpoint}`, fetchData);
    };
    const ShowBoard = (receivedPlayedTime, receivedRewards) => {
        Board.style.display = "flex";
        let playedTime = {...receivedPlayedTime};
        PlayedTimeInterval = setInterval(() => {
            playedTime.seconds++;
            if(playedTime.seconds === 60) {
                playedTime.minutes++;
                playedTime.seconds = 0;
            }
            if(playedTime.minutes === 60) {
                playedTime.hours++;
                playedTime.minutes = 0;
            }
            if(playedTime.hours === 24) {
                playedTime.days++;
                playedTime.hours = 0;
            }
            BoardHeaderTimerDisplayer.innerText = `${playedTime.days}d ${playedTime.hours}h ${playedTime.minutes}m ${playedTime.seconds}s`
        }, 1000);
        SetupRewards(receivedRewards);
    };

    const SetupRewards = (rewards) => {
        BoardRewards.innerHTML = "";
        const currentDate = new Date();
        for(let i=0; i < rewards.length; i++) {
            const reward = rewards[i];
            const rewardElement = document.createElement("div");
            rewardElement.innerHTML = `<div class="board-reward-title">Den ${reward.day} - ${reward.amount}${reward.type == "cash" ? "$" : "ks"}</div>`;
            rewardElement.classList.add("board-reward");

            const rewardStatus = document.createElement("div");
            rewardStatus.classList.add("board-reward-status");
            const isLocked = (!reward.claimed && (currentDate.getDate() > reward.day || currentDate.getDate() < reward.day));
            rewardStatus.innerHTML = (
                isLocked && !reward.claimed ? `<i class="fas fa-lock"></i>` : (
                    reward.claimed ? `<i class="fas fa-star"></i>` : `<i class="fas fa-lock-open"></i>`
                )
            );
            rewardStatus.style.backgroundColor = (
                isLocked && !reward.claimed ? "#e74c3c" : (
                    reward.claimed ? "#f1c40f" : "#2ecc71"
                )
            );

            const rewardImage = document.createElement("div");
            rewardImage.style.backgroundImage = `url(./assets/${reward.type == "cash" ? "money" : "lottery_ticket"}.png)`;
            rewardImage.classList.add("board-reward-image");
            if(!isLocked) 
                rewardImage.style.opacity = 1.0;

            rewardElement.append(rewardStatus);
            rewardElement.append(rewardImage);

            rewardElement.onclick = async () => {
                await UseFetch("claimReward", "POST", {
                    day: reward.day
                });
            };
            BoardRewards.append(rewardElement);
        }
    };

    const HideBoard = () => {
        Board.style.display = "none";
        clearInterval(PlayedTimeInterval);
        PlayedTimeInterval = null;
        BoardHeaderTimerDisplayer.innerText = `0d 0h 0m 0s`;
    };

    /*const GetMockedData = () => {
        const currentDate = new Date()
        const currentDaysInMonth = new Date(currentDate.getFullYear(), currentDate.getMonth(), 0).getDate();
        const testRewards = [];
        for(let i=1; i < currentDaysInMonth; i++) {
            testRewards.push({
                day: i,
                type: Math.floor((Math.random() * (2 - 1 + 1)) + 1) == 1 ? "cash" : "lottery",
                claimed: Math.floor((Math.random() * (2 - 1 + 1)) + 1) == 1 ? true : false,
                amount: 100,
            });
        }
        const playedTime = { days: 0, hours: 0, minutes: 0, seconds: 0};
        for (const [k,v] of Object.entries(playedTime)) {
            playedTime[k] = Math.floor(Math.random() * (30 - 1 + 1) + 1);
        }
        return [playedTime, testRewards];
    };

    const [testTime, testRewards] = GetMockedData()
    ShowBoard(testTime, testRewards);*/

    window.addEventListener('keyup', async (e) => {
        if (ListenedExitKeys.includes(e.code)) 
            await UseFetch("hideBoard", "POST");
    });

    window.addEventListener("message", (event) => {
        const data = event.data;
        if(data.action == "showBoard") {
            ShowBoard(data.playedTime, data.rewards);
        } else if(data.action == "hideBoard") {
            HideBoard();
        } else if(data.action == "updateBoardRewards") {
            SetupRewards(data.rewards);
        }
    });
};