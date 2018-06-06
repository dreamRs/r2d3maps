
// D3 cartogram

if (options.select) {
  div.append("div")
   .html(options.select_opts.select_html);
}

var svg = div.append("svg");

r2d3.onRender(function(json, div, width, height, options) {

  var projection, active = d3.select(null);

  var key, colorScale, new_range;


  if (options.projection == "Mercator") {
    projection = d3.geoMercator();
  } else if (options.projection == "ConicEqualArea") {
    projection = d3.geoConicEqualArea();
  } else if (options.projection == "NaturalEarth") {
    projection = d3.geoNaturalEarth1();
  } else {
    projection = d3.geoAlbers();
  }

  var path = d3.geoPath()
      .projection(projection);

  svg.attr("width", width)
     .attr("height", height);

  var statesbbox = topojson.feature(json, json.objects.states);

  // set projection
  projection
      .scale(1)
      .translate([0, 0]);

  var b = path.bounds(statesbbox),
      s = 0.9 / Math.max((b[1][0] - b[0][0]) / width, (b[1][1] - b[0][1]) / height),
      t = [(width - s * (b[1][0] + b[0][0])) / 2, (height - s * (b[1][1] + b[0][1])) / 2];

  projection
      .scale(s)
      .translate(t);

  //console.log(t);

  // main g
  var g = svg.append("g");

  if (!options.cartogram) {

    map = g.append("g")
            .attr("class", "feature")
            .selectAll("path")
            .data(topojson.feature(json, json.objects.states).features)
            .enter().append("path")
              .attr("fill", "#5f799c")
              .attr("stroke", options.stroke_col)
              .attr("stroke-width", options.stroke_width + "px")
              .attr("d", path);

    g.append("path")
      .datum(topojson.mesh(json, json.objects.states, function(a, b) { return a !== b; }))
      .attr("class", "mesh")
      .attr("d", path);

  } else {

    key = options.colors.color_var;
    var colors_brk = options.colors.scale[key].colors;
    var var_brk = options.colors.scale[key].breaks_var;
    var var_rng = options.colors.scale[key].range_var;
    colorScale = d3.scaleThreshold()
               .domain(var_brk)
               .range(colors_brk);

    //var states = svg.append("g");
    var layer = g.attr("id", "layer"),
        states = layer.append("g")
                    .attr("id", "states")
                    .selectAll("path");

    //console.log(JSON.stringify(features));

    var topology,
    		geometries,
    		rawData,
    		dataById = {},
    		carto = d3.cartogram()
      		.projection(projection)
      		.properties(function(d) {
      			return dataById.get(d.id);
      		})
      		.value(function(d) {
      			return +d.properties[key];
      		});


  		geometries = json.objects.states.geometries;
  		//console.log(JSON.stringify(geometries));
      rawData = options.json_data;
      dataById = d3.nest()
      	.key(function(d) {
      		return d.id;
      	})
      	.rollup(function(d) {
      		return d[0];
      	})
      	.map(rawData);
      //console.log(JSON.stringify(dataById));
      init();
      update();

    if (options.select) {
      var selectInput = d3.select("#" + options.select_opts.id);
      selectInput.on("change", function(e) {
        key = options.select_opts.choices[this.selectedIndex];
        var_brk = options.colors.scale[key].breaks_var;
        colors_brk = options.colors.scale[key].colors;
        colorScale.domain(var_brk);
        colorScale.range(colors_brk);
    		update();
      });

    }

    function init() {
      var features = carto.features(json, geometries),
        		path = d3.geoPath()
        		.projection(projection);
        	//console.log(JSON.stringify(features));
        	states = states.data(features)
        		.enter()
        		.append("path")
        		.attr("class", "state")
        		.attr("id", function(d) {
        		  //console.log(JSON.stringify(d));
        		  return d.properties.id;
        		})
        		.attr("fill", "#fafafa")
        		.attr("stroke", options.stroke_col)
            .attr("stroke-width", options.stroke_width + "px")
        		.attr("d", path);
        	states.append("title");
        	update();
        	parseHash();
      }

      function reset() {
         var features = carto.features(json, geometries),
          		path = d3.geoPath()
          		.projection(projection);
          	states.data(features)
          		.transition()
          		.duration(750)
          		.ease(d3.easeLinear)
          		.attr("fill", "#fafafa")
          		.attr("d", path);
          	states.select("title")
          		.text(function(d) {
          			return d.properties.name;
          		});
      }

    	function update() {
    		//var key = options.key,
    			//fmt = (typeof field.format === "function") ?
    			//field.format :
    			//d3.format(field.format || ","),
    			value = function(d) {
    			  //console.log(JSON.stringify(d)); // null here
    			  return +d.properties[key];
    			},
    			values = states.data()
      			.map(value)
      			.filter(function(n) {
      				return !isNaN(n);
      			})
      			.sort(d3.ascending),
    			lo = values[0],
    			hi = values[values.length - 1];
    		//var color = d3.scaleLinear()
    		//	.range(colors)
    		//	.domain(lo < 0 ? [lo, 0, hi] : [lo, d3.mean(values), hi]);
    		// normalize the scale to positive numbers
    		var scale2 = d3.scaleLinear()
    			.domain([lo, hi])
    			.range([1, 200]);
    		//console.log(scale2.domain());
    		// tell the cartogram to use the scaled values
    		carto.value(function(d) {
    			return scale2(value(d));
    		});

    		// generate the new features, pre-projected
    		var features = carto(json, geometries).features;
    		//console.log(JSON.stringify(features));
    		// update the data
    		states.data(features);
    		states.transition()
    			.duration(750)
    			.ease(d3.easeLinear)
    			.attr("fill", function(d) {
    				return colorScale(value(d));
    			})
    			.attr("d", carto.path);
    	}

      function parseHash() {
      	var parts = location.hash.substr(1).split("/"),
      		desiredFieldId = parts[0];
      	//field = fieldsById.get(desiredFieldId) || fields[0];
      	////fieldSelect.property("selectedIndex", fields.indexOf(field));
      }

  }

});





