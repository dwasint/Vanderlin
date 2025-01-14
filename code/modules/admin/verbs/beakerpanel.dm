/proc/reagentsforbeakers()
	. = list()
	for(var/t in subtypesof(/datum/reagent))
		var/datum/reagent/R = t
		. += list(list("id" = t, "text" = initial(R.name)))

	. = json_encode(.)

/proc/beakersforbeakers()
	. = list()
	for(var/t in subtypesof(/obj/item/reagent_containers))
		var/obj/item/reagent_containers/C = t
		. += list(list("id" = t, "text" = initial(C.name), "volume" = initial(C.volume)))

	. = json_encode(.)

/datum/admins/proc/beaker_panel_act(list/href_list)
	switch (href_list["beakerpanel"])
		if ("spawncontainer")
			var/containerdata = json_decode(href_list["container"])
			var/obj/item/reagent_containers/container = beaker_panel_create_container(containerdata, get_turf(usr))
			log_game("[key_name(usr)] spawned a [container] containing [pretty_string_from_reagent_list(container.reagents.reagent_list)]")

/datum/admins/proc/beaker_panel_create_container(list/containerdata, location)
	var/containertype = text2path(containerdata["container"])
	var/obj/item/reagent_containers/container =  new containertype(location)
	var/datum/reagents/reagents = container.reagents
	for(var/datum/reagent/R in reagents.reagent_list) // clear the container of reagents
		reagents.remove_reagent(R.type,R.volume)
	for (var/list/item in containerdata["reagents"])
		var/datum/reagent/reagenttype = text2path(item["reagent"])
		var/amount = text2num(item["volume"])
		if ((reagents.total_volume + amount) > reagents.maximum_volume)
			reagents.maximum_volume = reagents.total_volume + amount
		reagents.add_reagent(reagenttype, amount)
	return container

/datum/admins/proc/beaker_panel()
	set category = "Debug"
	set name = "Spawn reagent container"
	if(!check_rights())
		return

	var/datum/asset/asset_datum = get_asset_datum(/datum/asset/simple/namespaced/common)
	asset_datum.send()
	//Could somebody tell me why this isn't using the browser datum, given that it copypastes all of browser datum's html
	var/dat = {"
		<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Paint Canvas</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            margin: 0;
            padding: 0;
        }
        .container {
            display: flex;
            flex-direction: column;
            align-items: center;
            padding: 10px;
        }
        canvas {
            border: 1px solid black;
            cursor: crosshair;
        }
        .palette {
            display: flex;
            margin-top: 10px;
        }
        .palette-color {
            width: 24px;
            height: 24px;
            margin-right: 5px;
            border: 2px solid black;
            cursor: pointer;
        }
        .palette-color.selected {
            border-color: lightblue;
        }
        .buttons {
            margin-top: 10px;
        }
    </style>
</head>
<body>
    <div class="container">
        <canvas id="paintCanvas" width="300" height="300"></canvas>
        <div class="palette" id="palette"></div>
        <div class="buttons">
            <button id="toggleGrid">Toggle Grid</button>
            <button id="finalize">Finalize</button>
        </div>
    </div>
    <script>
        (function () {
            var canvas = document.getElementById('paintCanvas');
            var ctx = canvas.getContext('2d');
            var isDrawing = false;
            var drawingColor = '#000000';
            var showGrid = false;
            var palette = document.getElementById('palette');
            var gridData = Array(36).fill(null).map(function () {
                return Array(36).fill('#FFFFFF');
            });

            function drawGrid() {
                ctx.clearRect(0, 0, canvas.width, canvas.height);
                var scale = canvas.width / 36;

                for (var x = 0; x < gridData.length; x++) {
                    for (var y = 0; y < gridData\[x\].length; y++) {
                        ctx.fillStyle = gridData\[x\]\[y\];
                        ctx.fillRect(x * scale, y * scale, scale, scale);
                        if (showGrid) {
                            ctx.strokeStyle = '#888888';
                            ctx.lineWidth = 0.5;
                            ctx.strokeRect(x * scale, y * scale, scale, scale);
                        }
                    }
                }
            }

            function getCanvasCoords(event) {
                var rect = canvas.getBoundingClientRect();
                var x = Math.floor((event.clientX - rect.left) / (canvas.width / 36));
                var y = Math.floor((event.clientY - rect.top) / (canvas.height / 36));
                return { x: x, y: y };
            }

            function drawPoint(x, y, color) {
                if (x >= 0 && x < 36 && y >= 0 && y < 36) {
                    gridData\[x\]\[y\] = color;
                    drawGrid();
                }
            }

            canvas.addEventListener('mousedown', function (event) {
                isDrawing = true;
                var coords = getCanvasCoords(event);
                drawPoint(coords.x, coords.y, drawingColor);
            });

            canvas.addEventListener('mousemove', function (event) {
                if (isDrawing) {
                    var coords = getCanvasCoords(event);
                    drawPoint(coords.x, coords.y, drawingColor);
                }
            });

            canvas.addEventListener('mouseup', function () {
                isDrawing = false;
            });

            canvas.addEventListener('mouseout', function () {
                isDrawing = false;
            });

            document.getElementById('toggleGrid').addEventListener('click', function () {
                showGrid = !showGrid;
                drawGrid();
            });

            document.getElementById('finalize').addEventListener('click', function () {
                alert('Canvas finalized!');
            });

            var colors = \['#FF0000', '#00FF00', '#0000FF', '#FFFF00', '#FF00FF', '#00FFFF', '#000000', '#FFFFFF'\];

            colors.forEach(function (color) {
                var colorDiv = document.createElement('div');
                colorDiv.className = 'palette-color';
                colorDiv.style.backgroundColor = color;
                colorDiv.addEventListener('click', function () {
                    drawingColor = color;
                    var selected = document.querySelector('.palette-color.selected');
                    if (selected) {
                        selected.classList.remove('selected');
                    }
                    colorDiv.classList.add('selected');
                });
                palette.appendChild(colorDiv);
            });

            drawGrid();
        })();
    </script>
</body>
</html>

	"}

	usr << browse(dat, "window=beakerpanel;size=1100x720")
