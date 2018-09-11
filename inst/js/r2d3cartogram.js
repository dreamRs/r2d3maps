
// D3 cartogram

var el = div.node();
var shadowRoot = el.parentNode;
var host = shadowRoot.host;
var id;
if (typeof host != 'undefined') {
  id = host.id;
}

r2d3.onRender(function(json, div, width, height, options) {


  if (options.select) {
    div.append("div")
     .html(options.select_opts.select_html);
  }

  var svg = div.append("svg");

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
  //projection.fitSize([width, height], statesbbox);

  // set projection
  projection
      .scale(1)
      .translate([0, 0]);

  // Tooltip
  var divTooltip = div.append("div")
    .attr("class", "tooltip")
    .style("opacity", 0);

  var b = path.bounds(statesbbox),
      s = 0.9 / Math.max((b[1][0] - b[0][0]) / width, (b[1][1] - b[0][1]) / height),
      t = [(width - s * (b[1][0] + b[0][0])) / 2, (height - s * (b[1][1] + b[0][1])) / 2];

  projection
      .scale(s)
      .translate(t);

  //console.log(t);

  // main g
  var g = svg.append("g");

  if (options !== null) {
    if (typeof options.labs != 'undefined') {
      if (typeof options.labs.title != 'undefined') {
        var title = g.append("g")
            .attr("class", "title")
            .attr("transform", "translate(0,18)");
        title.append("text")
            .attr("class", "title")
            .attr("x", 0)
            .attr("y", -4)
            .attr("fill", "#000")
            .attr("text-anchor", "start")
            .attr("font-weight", "bold")
            .attr("font-size", "110%")
            .text(options.labs.title);
      }
      if (typeof options.labs.caption != 'undefined') {
        g.append("text")
          .attr("class", "caption")
          .attr("x", width)
          .attr("y", height-5)
          //.attr("startOffset", "100%")
          .attr("text-anchor", "end")
          .attr("font-size", "90%")
          .text(options.labs.caption);
      }
    } else {
      //console.log("nope");
    }
  }

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
    var ticks_opts = options.colors.scale[key].ticks;
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


    if (options.legend) {
      var gc = svg.append("g")
      	.attr("width", 300)
      	.attr("class", "key")
      	.attr("transform", "translate(10," + (height - 30) + ")");

      var rectbrk = gc.selectAll("rect")
      	.data(colorScale.range().map(function(d) {
      		d = colorScale.invertExtent(d);
      		if (d[0] === null) d[0] = x.domain()[0];
      		if (d[1] === null) d[1] = x.domain()[1];
      		return d;
      	  }))
      	.enter();
      rectbrk.append("rect")
      	.attr("height", 8)
      	//.attr("x", function(d) { return x(d[0]); })
      	//.attr("width", function(d) { return x(d[1]) - x(d[0]); })
      	.attr("x", function(d, i) { return ticks_opts.rect_x[i]; })
      	.attr("width", function(d, i) { return ticks_opts.rect_width[i]; })
      	.attr("fill", function(d) { return colorScale(d[0]); });
      rectbrk.insert("text")
      	.attr("class", "tick-label")
      	.attr("text-anchor", "middle")
      	.attr("font-size", "70%")
      	.attr("x", function(d, i) { return ticks_opts.axis_tick_pos[i]; })
      	.attr("y", 20)
      	.text(function(d, i) {
      	  var lib = ticks_opts.axis_tick_lib[i];
      	  if (typeof lib != 'undefined') {
      	    if (options.legend_opts.d3_format) {
        		  return d3.format(options.legend_opts.d3_format)(lib);
        	  } else {
        		  return options.legend_opts.prefix + lib + options.legend_opts.suffix;
        	  }
      	  }
      	});

      gc.append("text")
      	.attr("class", "caption")
      	.attr("x", 0)
      	.attr("y", -6)
      	.attr("fill", "#000")
      	.attr("text-anchor", "start")
      	.attr("font-size", "80%")
      	.attr("font-weight", "bold")
      	.text(options.legend_opts.title);
    }

    if (options.select) {

      var selectInput = d3.select("#" + options.select_opts.id);
      //console.log(selectInput);
      //var selectInput = document.getElementById(options.select_opts.id);
      selectInput.on("change", function(e) {
      //selectInput.addEventListener("change", function(e) {
        key = options.select_opts.choices[this.selectedIndex];
        var_brk = options.colors.scale[key].breaks_var;
        colors_brk = options.colors.scale[key].colors;
        colorScale.domain(var_brk);
        colorScale.range(colors_brk);
    		update();
      });

    }

    if (HTMLWidgets.shinyMode) {
      if (typeof id != 'undefined') {
        Shiny.addCustomMessageHandler('update-r2d3maps-continuous-breaks-' + id, function(proxy) {
          key = proxy.data.color_var;
          var_brk = proxy.data.scale[key].breaks_var;
          colors_brk = proxy.data.scale[key].colors;
          var_rng = proxy.data.scale[key].range_var;
          ticks_opts =  proxy.data.scale[key].ticks;
          colorScale.domain(var_brk);
          if (colors_brk !== null) {
            colorScale.range(colors_brk);
          }
          update();
          if (options.legend) {
            rectbrk.selectAll("rect").remove();
            rectbrk.selectAll("text.tick-label").remove();
            rectbrk = gc.selectAll("rect")
            	.data(colorScale.range().map(function(d) {
            		d = colorScale.invertExtent(d);
            		if (d[0] === null) d[0] = x.domain()[0];
            		if (d[1] === null) d[1] = x.domain()[1];
            		return d;
            	  }))
            	.enter();

            rectbrk.append("rect")
            	  .attr("height", 8)
            	  .attr("x", function(d, i) { return ticks_opts.rect_x[i]; })
            	  .attr("width", function(d, i) { return ticks_opts.rect_width[i]; })
            	  .attr("fill", function(d) { return colorScale(d[0]); });
            rectbrk.insert("text")
            	  .attr("class", "tick-label")
            	  .attr("text-anchor", "middle")
            	  .attr("font-size", "70%")
            	  .attr("x", function(d, i) { return ticks_opts.axis_tick_pos[i]; })
            	  .attr("y", 20)
            	  .text(function(d, i) {
            		var lib = ticks_opts.axis_tick_lib[i];
            		if (typeof lib != 'undefined') {
            		  if (options.legend_opts.d3_format) {
            			return d3.format(options.legend_opts.d3_format)(lib);
            		  } else {
            			return options.legend_opts.prefix + lib + options.legend_opts.suffix;
            		  }
            		}
            	  });
          }
        });
      }
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
    			  var val = d.properties[key];
    			  if (isNaN(val)) {
    			    val = 0;
    			  }
    			  return +val;
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

    		if (options.tooltip) {

          // Tooltip
          states
                .on("mouseover", function(d, i) {
                      d3.select(this).attr("opacity", 0.5);
                      // console.log(options.tooltip_value[i]);
                      if (options.tooltip_value[i] !== null) {
                        var mouse = d3.mouse(this);
                        //console.log(JSON.stringify(mouse));
                        divTooltip.transition()
                          .duration(200)
                          .style("opacity", 0.9);
                        divTooltip.html(options.tooltip_value[i])
                          .style("left", (mouse[0]) + "px")
                          .style("top", (mouse[1]) + "px");
                      }
                    })
                .on("mouseout", function(d) {
                        d3.select(this).attr("opacity", 1);
                        divTooltip.transition()
                            .duration(500)
                            .style("opacity", 0);
                    });

        }
    	}

      function parseHash() {
      	var parts = location.hash.substr(1).split("/"),
      		desiredFieldId = parts[0];
      	//field = fieldsById.get(desiredFieldId) || fields[0];
      	////fieldSelect.property("selectedIndex", fields.indexOf(field));
      }

  }

});





