window.onload = async () => {
    const ResourceName = "strin_vehicleshop";
    const SortingButton = document.getElementById("price-sort-button");
    const CategoryButton = document.getElementById("category-button");
    const SearchInput = document.getElementById("vehicle-search-input");
    let sortingType = "descending";
    let currentCategory = "all";
    let search = "";
    let loadedVehicles = [];
    let loadedCategories = {};
    let shopData = {};
    let cachedVehicles = [];
    let isCategoryMenuOpen = false;

    const CreateVehicle = (vehicleData) => {
        const vehicle = document.createElement("div");
        vehicle.setAttribute("id", vehicleData.id);
        vehicle.classList.add("vehicle");

        const vehicleImage = document.createElement("div");
        vehicleImage.classList.add("vehicle-image");
        vehicleImage.style.backgroundImage = `url("images/${vehicleData.hash}.jpg")`

        const vehicleInfo = document.createElement("div");
        vehicleInfo.classList.add("vehicle-info");

        const vehicleLabel = document.createElement("div");
        vehicleLabel.classList.add("vehicle-label");
        vehicleLabel.textContent = vehicleData.label ?? vehicleData.name;

        const vehiclePrice = document.createElement("div");
        vehiclePrice.classList.add("vehicle-price");
        vehiclePrice.textContent = `${new Intl.NumberFormat().format(vehicleData.price)}$`;

        vehicleInfo.appendChild(vehicleLabel);
        vehicleInfo.appendChild(vehiclePrice);

        vehicle.appendChild(vehicleImage);
        vehicle.appendChild(vehicleInfo);

        vehicle.onclick = () => {
            fetch(`https://${ResourceName}/buyVehicle`, {
                method: "POST",
                body: JSON.stringify(vehicleData),
            });
        };

        return vehicle;
    };

    const CreateVehicleRow = (rowId) => {
        const vehicleRow = document.createElement("div");
        vehicleRow.setAttribute("id", `vehicle-row-${rowId}`);
        vehicleRow.classList.add("vehicle-row");
        return vehicleRow;
    };

    const LoadShop = () => {
        SortVehicles();
        const shopContainer = document.getElementById("vehicle-shop-container");
        shopContainer.style.display = "block";

        const shopTitle = document.getElementById("vehicle-shop-front-title");
        shopTitle.textContent = shopData.title ?? "Prodejna vozidel";

        const shopSubtitle = document.getElementById("vehicle-shop-front-subtitle");
        shopSubtitle.textContent = shopData.subtitle ?? "To nejlepší na trhu pouze a jedině u nás!";

        const shopFrontContainer = document.getElementById("vehicle-shop-front-container");
        shopFrontContainer.style.backgroundImage = `url("${`images/${shopData.frontImage}` ?? "images/pdm.jpg"}")` 

        const carSelection = document.getElementById("vehicle-shop-car-selection");
        const vehicleRows = [CreateVehicleRow(1)]
        loadedVehicles.forEach((v,i) => {
            const luaIndex = 1 + i;

            const vehicle = CreateVehicle(v);
            vehicleRows[vehicleRows.length - 1].appendChild(vehicle);
            
            if(luaIndex % 3 == 0)
                vehicleRows.push(CreateVehicleRow(vehicleRows.length + 1));
        });
        vehicleRows.forEach((row) => {
            carSelection.appendChild(row);
        });
    };

    const HideShop = () => {
        SortingButton.click();
        const shopContainer = document.getElementById("vehicle-shop-container");
        shopContainer.style.display = "none";
        loadedVehicles = [];
        loadedCategories = {};
        shopData = {};
        sortingType = "descending";
        currentCategory = "all";
        isCategoryMenuOpen = false
        const carSelection = document.getElementById("vehicle-shop-car-selection");
        carSelection.innerHTML = "";
        const categoryMenu = document.getElementById("vehicle-category-menu");
        categoryMenu.style.display = "none";
        categoryMenu.innerHTML = "";
        cachedVehicles = [];
        SearchInput.value = "";
    };

    const SortVehicles = () => {
        if(sortingType == "ascending") {
            loadedVehicles.sort((a,b) => a.price - b.price);
        } else if(sortingType == "descending") {
            loadedVehicles.sort((a,b) => b.price - a.price);
        }
    };

    const SelectCategoryVehicles = () => {
        loadedVehicles = cachedVehicles;
        const filteredVehicles = currentCategory == "all" ? loadedVehicles : loadedVehicles.filter((o) => o.category == currentCategory);
        loadedVehicles = filteredVehicles;
    };

    SortingButton.onclick = () => {
        const sortingArrowContainer = document.getElementById("sorting-type");
        sortingArrowContainer.innerHTML = "";
        const newSortingArrow = document.createElement("i");
        newSortingArrow.classList.add("fas");
        if(sortingType == "ascending") {
            newSortingArrow.classList.add("fa-chevron-down");
            sortingType = "descending";
        } else if(sortingType == "descending") {
            newSortingArrow.classList.add("fa-chevron-up");
            sortingType = "ascending";
        }
        sortingArrowContainer.appendChild(newSortingArrow);
        const carSelection = document.getElementById("vehicle-shop-car-selection");
        carSelection.innerHTML = "";
        LoadShop();
    };

    CategoryButton.onclick = () => {
        if(!isCategoryMenuOpen) {
            const categoryMenu = document.getElementById("vehicle-category-menu");
            for(const [key, value] of Object.entries(loadedCategories)) {
                const category = document.createElement("div");
                category.setAttribute("id", `category-${key}`);
                category.classList.add("vehicle-category");
                category.textContent = value;
                category.onclick = () => {
                    currentCategory = key;
                    SelectCategoryVehicles();
                    CloseCategoryMenu();
                    const carSelection = document.getElementById("vehicle-shop-car-selection");
                    carSelection.innerHTML = "";
                    LoadShop();
                };
                categoryMenu.appendChild(category);
            };

            categoryMenu.style.top = CategoryButton.offsetTop;
            categoryMenu.style.left = CategoryButton.offsetLeft;
            categoryMenu.style.marginTop = "8px";
            categoryMenu.style.display = "flex";
            isCategoryMenuOpen = true
        } else {
            CloseCategoryMenu();
        }
    };

    SearchInput.oninput = (e) => {
        search = e.target.value;
        if(search != "") {
            SelectCategoryVehicles();
            loadedVehicles = loadedVehicles.filter(
                o => o.label.toLowerCase().includes(search.toLowerCase())
            );
        } else {
            SelectCategoryVehicles();
        }
        const carSelection = document.getElementById("vehicle-shop-car-selection");
        carSelection.innerHTML = "";
        LoadShop();
    };

    const CloseCategoryMenu = () => {
        isCategoryMenuOpen = false
        const categoryMenu = document.getElementById("vehicle-category-menu");
        categoryMenu.style.display = "none";
        categoryMenu.style.marginTop = "0px";
        categoryMenu.innerHTML = "";
    };

    window.onclick = (e) => {
        if(isCategoryMenuOpen && (!e.target || !e.target.id || !(e.target.id.includes("category")))) {
            CloseCategoryMenu();
        }
    };

    window.onkeydown = (e) => {
        if(e.key == "Escape")
            fetch(`https://${ResourceName}/hideShop`, {method: "POST"});
    };

    window.addEventListener("message", (event) => {
        const {action, catalog, shop} = event.data;
        if(action == "loadShop") {
            loadedVehicles = catalog.vehicles;
            loadedCategories["all"] = "Všechny";
            for(const [key, value] of Object.entries(catalog.categories)) {
                loadedCategories[key] = value;
            }
            cachedVehicles = loadedVehicles;
            shopData = shop;
            LoadShop();
        } else if(action == "hideShop") {
            HideShop();
        }
    });
};