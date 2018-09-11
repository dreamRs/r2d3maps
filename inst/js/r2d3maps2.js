// D3 maps

var el = div.node();
var shadowRoot = el.parentNode;
var host = shadowRoot.host;
var id;
if (typeof host != 'undefined') {
  id = host.id;
}
//console.log(id);

r2d3.onRender(function(json, div, width, height, options) {
  //console.log(JSON.stringify(svg.select(function() { return this.parentNode.id; })));
  // utils
  // https://gist.github.com/mbostock/4699541
  function clicked(d) {
    if (active.node() === this) return reset();
    active.classed("active", false);
    active = d3.select(this).classed("active", true);
    var bounds = path.bounds(d),
        dx = bounds[1][0] - bounds[0][0],
        dy = bounds[1][1] - bounds[0][1],
        x = (bounds[0][0] + bounds[1][0]) / 2,
        y = (bounds[0][1] + bounds[1][1]) / 2,
        scale = 0.8 / Math.max(dx / width, dy / height),
        translate = [width / 2 - scale * x, height / 2 - scale * y];
    g.transition()
        .duration(750)
        .style("stroke-width", 1.5 / scale + "px")
        .attr("transform", "translate(" + translate + ")scale(" + scale + ")");
  }
  function reset() {
    active.classed("active", false);
    active = d3.select(null);
    g.transition()
        .duration(750)
        .style("stroke-width", "1.5px")
        .attr("transform", "");
  }
  // https://bl.ocks.org/iamkevinv/0a24e9126cd2fa6b283c6f2d774b69a2
  function zoomed() {
    g.style("stroke-width", 1.5 / d3.event.transform.k + "px");
    g.attr("transform", d3.event.transform); // updated for d3 v4
  }

  // global variables
  var map, active = d3.select(null),
      legend_prefix, legend_suffix, legend_d3_format, legend_d3_locale, legend_title;


  // Legend options
  if (options.legend) {
    legend_prefix = options.legend_opts.prefix;
    legend_suffix = options.legend_opts.suffix;
    legend_d3_format = options.legend_opts.d3_format;
    legend_d3_locale = options.legend_opts.d3_locale;
    if (legend_d3_locale) {
      d3.formatDefaultLocale(legend_d3_locale);
    }
    legend_title = options.legend_opts.title;
  }
  if (HTMLWidgets.shinyMode) {
    if (typeof id != 'undefined') {
  	Shiny.addCustomMessageHandler('update-r2d3maps-legend-' + id,
  	  function(proxy) {
  		  legend_prefix = proxy.data.prefix;
        legend_suffix = proxy.data.suffix;
        legend_d3_format = proxy.data.d3_format;
        legend_title = proxy.data.title;
  	 });
    }
  }

  // Tooltip
  var tooltip = false;
  var tooltip_value;
  if (options.tooltip) {
    tooltip = true;
    tooltip_value = options.tooltip_value;
  }
  if (HTMLWidgets.shinyMode) {
    if (typeof id != 'undefined') {
  	Shiny.addCustomMessageHandler('update-r2d3maps-tooltip-' + id,
  	  function(proxy) {
  		  tooltip = true;
        tooltip_value = proxy.data.tooltip_value;
  	 });
    }
  }

  div.selectAll("svg").remove();
  var svg = div.append("svg");
  svg.attr("width", width)
     .attr("height", height);

  var mapInit = init_map(json, width, height, options.projection),
      projection = mapInit.projection,
      path = mapInit.path,
      states = mapInit.states;

  // Tooltip
  var divTooltip = div.append("div")
    .attr("class", "tooltip")
    .style("opacity", 0);

  // main g
  var g = svg.append("g");

  // colors
  if (options !== null) {
    if (typeof options.colors != 'undefined') {

      // discrete colors
      if (options.colors.color_type == 'discrete') {

        var ordinal = d3.scaleOrdinal()
          .domain(options.colors.values)
          .range(options.colors.colors);
        map = g.append("g")
            .attr("class", "feature")
            .selectAll("path")
            .data(topojson.feature(json, json.objects.states).features)
            .enter().append("path")
              .attr("fill", function(d) { return ordinal(d.properties[options.colors.color_var]); })
              .attr("stroke", options.stroke_col)
              .attr("stroke-width", options.stroke_width + "px")
              .attr("d", path);


        if (options.legend) {
          // Legend
          var gd = g.append("g")
              .attr("class", "legendThreshold")
              .attr("transform", "translate(10," + (height/2) + ")");
          gd.append("text")
              .attr("class", "caption")
              .attr("x", 0)
              .attr("y", -6)
              .text(legend_title);
          var legend = d3.legendColor()
              .orient("vertical")
              .labels(function (d) { return options.colors.values[d.i]; })
              .cellFilter(function (d) { if (typeof d.label === 'undefined') { return false; } else { return true; } })
              .shapePadding(4)
              .scale(ordinal);
          g.select(".legendThreshold")
              .call(legend);
        }

      }

      // continuous breaks colors
      if (options.colors.color_type == 'continuous-breaks') {

        var key_brk = options.colors.color_var;
        var colors_brk = options.colors.scale[key_brk].colors;
        var var_brk = options.colors.scale[key_brk].breaks_var;
        var var_rng = options.colors.scale[key_brk].range_var;
        var ticks_opts = options.colors.scale[key_brk].ticks;

        var x = d3.scaleLinear()
                  .range([0, 300])
                  .domain(var_rng);
        var colorBreaks = d3.scaleThreshold()
                            .domain(var_brk)
                            .range(colors_brk);

        if (options.legend) {
          var gc = svg.append("g")
            .attr("width", 300)
            .attr("class", "key")
            .attr("transform", "translate(10," + (height - 30) + ")");

          var rectbrk = gc.selectAll("rect")
            .data(colorBreaks.range().map(function(d) {
                d = colorBreaks.invertExtent(d);
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
                .attr("fill", function(d) { return colorBreaks(d[0]); });
          rectbrk.insert("text")
                .attr("class", "tick-label")
                .attr("text-anchor", "middle")
                .attr("font-size", "70%")
                .attr("x", function(d, i) { return ticks_opts.axis_tick_pos[i]; })
                .attr("y", 20)
                .text(function(d, i) {
                  var lib = ticks_opts.axis_tick_lib[i];
                  if (typeof lib != 'undefined') {
                    if (legend_d3_format) {
                      return d3.format(legend_d3_format)(lib);
                    } else {
                      return legend_prefix + lib + legend_suffix;
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
            .text(legend_title);


        }

        map = g.append("g")
            .attr("class", "feature")
            .selectAll("path")
            .data(topojson.feature(json, json.objects.states).features)
            .enter().append("path")
              .attr("fill", function(d) {
                //console.log(d.properties[options.colors.color_var]);
                var value = d.properties[key_brk];
                if (value == 'NA' | value == 'NaN') {
                  return options.colors.na_color;
                } else {
                  return colorBreaks(value);
                }
              })
              .attr("stroke", options.stroke_col)
              .attr("stroke-width", options.stroke_width + "px")
              .attr("d", path);

        if (HTMLWidgets.shinyMode) {
          if (typeof id != 'undefined') {
            Shiny.addCustomMessageHandler('update-r2d3maps-continuous-breaks-' + id,
              function(proxy) {
                key_brk = proxy.data.color_var;
                colors_brk = proxy.data.scale[key_brk].colors;
                var_brk = proxy.data.scale[key_brk].breaks_var;
                var_rng = proxy.data.scale[key_brk].range_var;
                ticks_opts =  proxy.data.scale[key_brk].ticks;
                if (typeof colors_brk != 'undefined') {
                  if (colors_brk !== null) {
                    colorBreaks.range(colors_brk);
                  }
                  colorBreaks.domain(var_brk);
                  x.domain(var_rng);
                  if (options.legend) {
                    rectbrk.selectAll("rect").remove();
                    rectbrk.selectAll("text.tick-label").remove();
                    rectbrk = gc.selectAll("rect")
                        .data(colorBreaks.range().map(function(d) {
                            d = colorBreaks.invertExtent(d);
                            if (d[0] === null) d[0] = x.domain()[0];
                            if (d[1] === null) d[1] = x.domain()[1];
                            return d;
                          }))
                        .enter();

                    rectbrk.append("rect")
                          .attr("height", 8)
                          .attr("x", function(d, i) { return ticks_opts.rect_x[i]; })
                          .attr("width", function(d, i) { return ticks_opts.rect_width[i]; })
                          .attr("fill", function(d) { return colorBreaks(d[0]); });
                    rectbrk.insert("text")
                          .attr("class", "tick-label")
                          .attr("text-anchor", "middle")
                          .attr("font-size", "70%")
                          .attr("x", function(d, i) { return ticks_opts.axis_tick_pos[i]; })
                          .attr("y", 20)
                          .text(function(d, i) {
                            var lib = ticks_opts.axis_tick_lib[i];
                            if (typeof lib != 'undefined') {
                              if (legend_d3_format) {
                                return d3.format(legend_d3_format)(lib);
                              } else {
                                return legend_prefix + lib + legend_suffix;
                              }
                            }
                          });
                    gc.selectAll("text.caption").remove();
                    gc.append("text")
                      .attr("class", "caption")
                      .attr("x", 0)
                      .attr("y", -6)
                      .attr("fill", "#000")
                      .attr("text-anchor", "start")
                      .attr("font-size", "80%")
                      .attr("font-weight", "bold")
                      .text(legend_title);

                  }
                }

                map.transition()
                		.duration(750)
                		//.ease("linear")
                		//.attr("fill", "#fafafa")
                		.attr("fill", function(d) {
                			if (d.properties[key_brk] == 'NA') {
                        return options.colors.na_color;
                      } else {
                        return colorBreaks(d.properties[key_brk]);
                      }
                		})
                		.attr("d", path);
            });
          }
          Shiny.addCustomMessageHandler('update-r2d3maps-legend-' + id,
        	  function(proxy) {
        		  legend_prefix = proxy.data.prefix;
              legend_suffix = proxy.data.suffix;
              legend_d3_format = proxy.data.d3_format;
              legend_title = proxy.data.title;
              gc.selectAll("text.caption").remove();
              gc.append("text")
                  .attr("class", "caption")
                  .attr("x", 0)
                  .attr("y", -6)
                  .attr("fill", "#000")
                  .attr("text-anchor", "start")
                  .attr("font-size", "80%")
                  .attr("font-weight", "bold")
                  .text(legend_title);
        	 });

        }

      }

      if (options.colors.color_type == 'continuous-gradient') {

        var key_gdt1 = options.colors.color_var;
        var colors_gdt1 = options.colors.scale[key_gdt1].colors;
        var colors_leg_gdt1 = options.colors.scale[key_gdt1].colors_legend;
        var leg_lab_gdt1 = options.colors.scale[key_gdt1].legend_label;
        var scale_var_gdt1 = options.colors.scale[key_gdt1].scale_var;
        var range_var_gdt1 = options.colors.scale[key_gdt1].range_var;

        // color scale for gradient
        var colorGradient = d3.scaleLinear()
            .range(colors_gdt1)
            .domain(scale_var_gdt1);
        var colorInterpolateGradient = d3.scaleLinear()
          	.domain(d3.extent(range_var_gdt1))
          	.range([0,1]);

        // legend for gradient
        if (options.legend) {
          var widthLegend = width/3; //Math.min(width/3, 300)

          //Append a defs (for definition) element to your SVG
          var defs = svg.append("defs");

          //Append a linearGradient element to the defs and give it a unique id
          var linearGradient = defs.append("linearGradient")
              .attr("id", options.colors.gradient_id);

          linearGradient
            .attr("x1", "0%")
            .attr("y1", "0%")
            .attr("x2", "100%")
            .attr("y2", "0%");
          //Append multiple color stops by using D3's data/enter step
          linearGradient.selectAll("stop")
              .data( colors_leg_gdt1 )
              .enter().append("stop")
              .attr("offset", function(d,i) { return i/(colors_leg_gdt1.length-1); })
              .attr("stop-color", function(d) { return d; });


          //Color Legend container
          var linearGradientSvg = svg.append("g")
          	.attr("class", "legendWrapper");

          //Draw the rectangle and fill with gradient
          linearGradientSvg.append("rect")
              .attr("width", widthLegend) //
              .attr("height", 10)
              .style("fill", "url(#" + options.colors.gradient_id + ")")
              .attr("x", 5)
              .attr("y", height-30);

          linearGradientSvg.append("text")
            .attr("class", "caption")
          	.attr("x", 5)
          	.attr("y", height-35)
          	.style("font-size", 14)
          	.style("text-anchor", "start")
          	.text(legend_title);

          linearGradientSvg.append("text")
            .attr("class", "tick-label")
          	.attr("x", 10)
          	.attr("y", height-5)
          	.style("font-size", 11)
          	.style("text-anchor", "middle")
          	.text(function() {
          	  if (legend_d3_format) {
          	    return d3.format(legend_d3_format)(leg_lab_gdt1[0]);
          	  } else {
          	    return legend_prefix + leg_lab_gdt1[0] + legend_suffix;
          	  }
          	});
          linearGradientSvg.append("text")
            .attr("class", "tick-label")
          	.attr("x", widthLegend/2+5)
          	.attr("y", height-5)
          	.style("font-size", 11)
          	.style("text-anchor", "middle")
          	.text(function() {
          	  if (legend_d3_format) {
          	    return d3.format(legend_d3_format)(leg_lab_gdt1[1]);
          	  } else {
          	    return legend_prefix + leg_lab_gdt1[1] + legend_suffix;
          	  }
          	});
          linearGradientSvg.append("text")
            .attr("class", "tick-label")
          	.attr("x", widthLegend)
          	.attr("y", height-5)
          	.style("font-size", 11)
          	.style("text-anchor", "middle")
          	.text(function() {
          	  if (legend_d3_format) {
          	    return d3.format(legend_d3_format)(leg_lab_gdt1[2]);
          	  } else {
          	    return legend_prefix + leg_lab_gdt1[2] + legend_suffix;
          	  }
          	});
        }
        // map with gradient
        map = g.append("g")
            .attr("class", "feature")
            .selectAll("path")
            .data(topojson.feature(json, json.objects.states).features)
            .enter().append("path")
              .attr("fill", function(d) {
                if (d.properties[key_gdt1] == 'NA') {
                  return options.colors.na_color;
                } else {
                  return colorGradient(colorInterpolateGradient(d.properties[key_gdt1]));
                }
              })
              .attr("stroke", options.stroke_col)
              .attr("stroke-width", options.stroke_width + "px")
              .attr("d", path);

        if (HTMLWidgets.shinyMode) {
            if (typeof id != 'undefined') {
              Shiny.addCustomMessageHandler('update-r2d3maps-continuous-gradient-' + id,
                function(proxy) {
                  key_gdt1 = proxy.data.color_var;
                  colors_gdt1 = proxy.data.scale[key_gdt1].colors;
                  if (proxy.data.scale[key_gdt1].colors_legend !== null) {
                    colors_leg_gdt1 = proxy.data.scale[key_gdt1].colors_legend;
                  }
                  leg_lab_gdt1 = proxy.data.scale[key_gdt1].legend_label;
                  scale_var_gdt1 = proxy.data.scale[key_gdt1].scale_var;
                  range_var_gdt1 = proxy.data.scale[key_gdt1].range_var;

                  colorGradient.domain(scale_var_gdt1);
                  colorInterpolateGradient.domain(d3.extent(range_var_gdt1));


                  if (colors_gdt1 !== null) {
                    colorGradient.range(colors_gdt1);
                  }

                  if (options.legend) {
                    linearGradient.selectAll("stop").remove();
                    //Append multiple color stops by using D3's data/enter step
                    linearGradient.selectAll("stop")
                        .data( colors_leg_gdt1 )
                        .enter().append("stop")
                        .attr("offset", function(d,i) { return i/(colors_leg_gdt1.length-1); })
                        .attr("stop-color", function(d) { return d; });

                    linearGradientSvg.selectAll("text.tick-label").remove();
                    linearGradientSvg.append("text")
                      .attr("class", "tick-label")
                    	.attr("x", 10)
                    	.attr("y", height-5)
                    	.style("font-size", 11)
                    	.style("text-anchor", "middle")
                    	.text(function() {
                    	  if (legend_d3_format) {
                    	    return d3.format(legend_d3_format)(leg_lab_gdt1[0]);
                    	  } else {
                    	    return legend_prefix + leg_lab_gdt1[0] + legend_suffix;
                    	  }
                    	});
                    linearGradientSvg.append("text")
                      .attr("class", "tick-label")
                    	.attr("x", widthLegend/2+5)
                    	.attr("y", height-5)
                    	.style("font-size", 11)
                    	.style("text-anchor", "middle")
                    	.text(function() {
                    	  if (legend_d3_format) {
                    	    return d3.format(legend_d3_format)(leg_lab_gdt1[1]);
                    	  } else {
                    	    return legend_prefix + leg_lab_gdt1[1] + legend_suffix;
                    	  }
                    	});
                    linearGradientSvg.append("text")
                      .attr("class", "tick-label")
                    	.attr("x", widthLegend)
                    	.attr("y", height-5)
                    	.style("font-size", 11)
                    	.style("text-anchor", "middle")
                    	.text(function() {
                    	  if (legend_d3_format) {
                    	    return d3.format(legend_d3_format)(leg_lab_gdt1[2]);
                    	  } else {
                    	    return legend_prefix + leg_lab_gdt1[2] + legend_suffix;
                    	  }
                    	});
                  }

                  map.transition()
                		.duration(750)
                		//.ease("linear")
                		//.attr("fill", "#fafafa")
                		.attr("fill", function(d) {
                			if (d.properties[key_gdt1] == 'NA') {
                        return options.colors.na_color;
                      } else {
                        return colorGradient(colorInterpolateGradient(d.properties[key_gdt1]));
                      }
                		})
                		.attr("d", path);
                }
              );
            }
            Shiny.addCustomMessageHandler('update-r2d3maps-legend-' + id,
          	  function(proxy) {
          		  legend_prefix = proxy.data.prefix;
                legend_suffix = proxy.data.suffix;
                legend_d3_format = proxy.data.d3_format;
                legend_title = proxy.data.title;
                linearGradientSvg.selectAll("text.caption").remove();
                linearGradientSvg.append("text")
                  .attr("class", "caption")
                	.attr("x", 5)
                	.attr("y", height-35)
                	.style("font-size", 14)
                	.style("text-anchor", "start")
                	.text(legend_title);
        	 });
        }
      }

    } else {

      map = g.append("g")
            .attr("class", "feature")
            .selectAll("path")
            .data(topojson.feature(json, json.objects.states).features)
            .enter().append("path")
              .attr("fill", "#5f799c")
              .attr("stroke", options.stroke_col)
              .attr("stroke-width", options.stroke_width + "px")
              .attr("d", path);

    }

  } else {

    g.append("path")
      .datum(states)
      .attr("class", "feature")
      .attr("d", path);

  }

  if (options !== null) {

    // Zooming
    if (options.zoom) {
      if (options.zoom_opts.click) {
        map.on("click", clicked);
      }
      if (options.zoom_opts.wheel) {
        var zoom = d3.zoom()
          .scaleExtent([1, 8])
          .on("zoom", zoomed);
        svg.call(zoom);
      }
    }

    // Shiny interaction
    if (options.shiny) {
      if (HTMLWidgets.shinyMode) {
        map.on(options.shiny_opts.action, function(d) {
          if (options.shiny_opts.layerId) {
            Shiny.onInputChange(options.shiny_opts.inputId, d.properties[options.shiny_opts.layerId]);
          } else {
            Shiny.onInputChange(options.shiny_opts.inputId, d.properties);
          }
        });
      }
    }

    if (tooltip) {

      // Tooltip
      g.selectAll("path")
            .on("mouseover", function(d, i) {
                  d3.select(this).attr("opacity", 0.5);
                  // console.log(options.tooltip_value[i]);
                  if (tooltip_value[i] !== null) {
                    var mouse = d3.mouse(this);
                    //console.log(JSON.stringify(mouse));
                    divTooltip.transition()
                      .duration(200)
                      .style("opacity", 0.9);
                    divTooltip.html(tooltip_value[i])
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

  g.append("path")
      .datum(topojson.mesh(json, json.objects.states, function(a, b) { return a !== b; }))
      .attr("class", "mesh")
      .attr("d", path);

});
