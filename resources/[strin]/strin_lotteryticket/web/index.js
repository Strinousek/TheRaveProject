window.onload = async () => {
    const Sleep = async (ms) => new Promise((res) => setTimeout(res, ms));
    const LotteryContainer = document.getElementById("lottery-container");
    const LotteryWinningNumbers = document.getElementById("lottery-winning-numbers");
    const LotterySlots = document.getElementById("lottery-slots");
    const LotteryConfirmButton = document.getElementById("lottery-confirm");
    const ResourceName = "strin_lotteryticket";

    const ShowLottery = async (numbers, winningNumbers) => {
        LotteryContainer.style.opacity = 1.0;
        LotteryWinningNumbers.textContent = winningNumbers.join("");
        numbers.forEach((number, i) => {
            const slot = document.createElement("div");
            slot.id = `lottery-slot-${1 + i}`;
            slot.classList.add("lottery-slot");
            slot.classList.add("hidden-slot");

            const textParagraph = document.createElement("p");
            textParagraph.textContent = number;

            slot.append(textParagraph);
            LotterySlots.append(slot);
        });

        for(let currentSlot=1; currentSlot <= numbers.length; currentSlot++) {
            const slot = document.getElementById(`lottery-slot-${currentSlot}`);
            slot.classList.add("current-slot");
            await Sleep(2000);
            slot.classList.remove("current-slot");
            slot.classList.remove("hidden-slot");
            const index = currentSlot - 1;
            if(numbers[index] === winningNumbers[index])
                slot.classList.add("winning-slot");
            if(currentSlot === numbers.length)
                LotteryConfirmButton.style.display = "flex";
        }
    };

    const HideLottery = async () => {
        LotteryContainer.style.opacity = "0";
        await Sleep(500);
        LotterySlots.innerHTML = "";
        LotteryConfirmButton.style.display = "none";
    };

    LotteryConfirmButton.onclick = () => {
        fetch(`https://${ResourceName}/confirm`, {
            method: "POST",
            body: JSON.stringify({}),
        });    
    };

    /*ShowLottery([
         5, 1, 7, 8 
    ], [
         9, 1, 3, 5 
    ]);*/

    window.addEventListener("message", (event) => {
        const data = event.data;
        if(data.action === "showLottery")
            ShowLottery(data.numbers, data.winningNumbers);
        else if(data.action === "hideLottery")
            HideLottery();
    });
    //await Sleep(2000);
    //HideLottery();
};