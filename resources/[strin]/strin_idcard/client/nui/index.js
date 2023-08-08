$(() => {
    const DisplayCard = (type, info) => {
        let chance = Math.floor(Math.random() * 101);
        const imagePrefix = type == "driving_license" ? "dl" : "id"
        $("#card-container").css("background", `url('./images/${
            imagePrefix
        }${
            chance <= 5 ? 1 : 0
        }.png')`);
        if(type == "driving_license") {
            $("#classes").text(info.classes.join(", "));
            $("#classes").show();
        }
        $("#firstname").text(info.firstname);
        $("#lastname").text(info.lastname);
        $("#dob").text(info.dateofbirth);
        $("#sex").text(info.sex);
        /*$("#hair").text(info.hairColor);
        $("#eyes").text(info.eyes);*/
        $("#height").text(info.height);
        $("#weight").text(info.weight);
        $("#creation-date").text(info.issuedOn);
        $("#card-container").show();
    };
    const HideCard = () => {
        $("#classes").hide();
        $("#card-container").hide();
    };

    window.addEventListener("message", (e) => {
        let data = e.data;
        if(data.display) {
            DisplayCard(data.type, data.info);
        } else {
            HideCard();
        };
    });
})