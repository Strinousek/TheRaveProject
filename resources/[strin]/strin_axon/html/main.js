$(() => {
	let date = "YEAR-MONTH-DAY";
	let time = "THOURS:MINUTES:SECONDSZ";
	let firstTime = new Date();
	const setTime = (currentTime) => {
		date = "YEAR-MONTH-DAY";
		time = "THOURS:MINUTES:SECONDSZ";
		// Date
		date = date.replace("YEAR", currentTime.getFullYear());
		if((currentTime.getUTCMonth()+1).toString().length == 1) {
			date = date.replace("MONTH", `0${currentTime.getUTCMonth()+1}`);
		} else {
			date = date.replace("MONTH", `${currentTime.getUTCMonth()+1}`);
		}
		if(currentTime.getUTCDate().toString().length == 1) {
			date = date.replace("DAY", `0${currentTime.getUTCDate()}`);
		} else {
			date = date.replace("DAY", `${currentTime.getUTCDate()}`);
		}
		// Time
		if(currentTime.getHours().toString().length == 1) {
			time = time.replace("HOURS", `0${currentTime.getHours()}`);
		} else {
			time = time.replace("HOURS", `${currentTime.getHours()}`);
		}
		if(currentTime.getMinutes().toString().length == 1) {
			time = time.replace("MINUTES", `0${currentTime.getMinutes()}`);
		} else {
			time = time.replace("MINUTES", `${currentTime.getMinutes()}`);
		}
		if(currentTime.getSeconds().toString().length == 1) {
			time = time.replace("SECONDS", `0${currentTime.getSeconds()}`);
		} else {
			time = time.replace("SECONDS", `${currentTime.getSeconds()}`);
		}
		$("#axon-date").text(date)
		$("#axon-time").text(time)
	};
	setTime(firstTime);
	let timeInterval = null
	const makeInterval = () => {
		timeInterval = setInterval(() => {
			let currentTime = new Date();
			setTime(currentTime);
		}, 1000);
	};
	window.addEventListener('message', (e) => {
		let data = e.data;
		if(data.display) {
			makeInterval();
			$("#axon-code").text(data.code)
			$("#axon-container").css("display", "flex");
		} else {
			clearInterval(timeInterval);
			timeInterval = null;
			$("#axon-container").css("display", "none");
		};
	})
})