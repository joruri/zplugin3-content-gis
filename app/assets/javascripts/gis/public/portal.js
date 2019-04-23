var OpenLayersPortalViewer = function(id, source, latitude, longitude, zoom, latitude2, longitude2) {
  if (source == "webtis") {
    var base = new ol.layer.Tile({
      source: new ol.source.XYZ({
        attributions: "<a href='https://maps.gsi.go.jp/development/ichiran.html' target='_blank'>国土地理院</a>",
        url: "//cyberjapandata.gsi.go.jp/xyz/std/{z}/{x}/{y}.png",
        projection: "EPSG:3857"
      })
    });
  } else {
    var base = new ol.layer.Tile({
      source: new ol.source.OSM(),
      type: 'base'
    });
  }
  var container = document.getElementById('popup');
  container.style.display = 'block';
  var content = document.getElementById('popup-content');
  var closer = document.getElementById('popup-closer');
  var popoverlay = new ol.Overlay({
    element: container,
    autoPan: true,
    autoPanAnimation: {
      duration: 250
    }
  });
  this._content = content;
  this._popoverlay = popoverlay;

  closer.onclick = function() {
    popoverlay.setPosition(undefined);
    closer.blur();
    return false;
  };

  this._map_canvas = new ol.Map({
    target: id,
    view: new ol.View({
      center: ol.proj.fromLonLat([longitude, latitude]),
      zoom: (zoom || 12),
      maxZoom: 18
    }),
    overlays: [popoverlay],
    layers: [base],
    controls: ol.control.defaults({
      attributionOptions: {
        collapsible: false
      }
    })
  });

  this._map_canvas.addControl(new ol.control.ScaleLine());
  this._map_canvas.addControl(new ol.control.ZoomSlider());
  this._map_canvas.addControl(new ol.control.FullScreen());

  if (latitude2 != undefined || longitude2 != undefined) {
    var extent = [longitude, latitude, longitude2, latitude2];
    extent = ol.extent.applyTransform(extent, ol.proj.getTransform("EPSG:4326", "EPSG:3857"));
    this._map_canvas.getView().fit(extent, this._map_canvas.getSize());
  }

  this._vector_layers = {};
  this._icon_styles   = {};

}

OpenLayersPortalViewer.prototype.create_vector_layer = function(options){
  if ( this._vector_layers[options.name] == null ){

    var cluster = new ol.source.Cluster({
      source: new ol.source.Vector({
        url: options.url,
        format: new ol.format.GeoJSON()
      }),
      distance: 5
    })

    this._vector_layers[options.name] = new ol.layer.Vector({
      source: cluster,
      visible: false
    });

    this._vector_layers[options.name].setStyle(function(feature, resolution) {
      const features = feature.get("features");
      if (features.length == 1) {
        selected = features[0];
        var icon = selected.get('icon');

        var styles = {
            'Point': new ol.style.Style({
              image: new ol.style.Icon({
                anchor: [0.5, 1],
                anchorXUnits: 'fraction',
                anchorYUnits: 'fraction',
                src: icon
              })
            }),
            'LineString': new ol.style.Style({
              stroke: new  ol.style.Stroke({
                color: 'green',
                width: 1
              })
            }),
            'Polygon': new ol.style.Style({
              stroke: new  ol.style.Stroke({
                color: 'blue',
                lineDash: [4],
                width: 3
              }),
              fill: new ol.style.Fill({
                color: 'rgba(0, 0, 255, 0.1)'
              })
            }),
            'Circle': new ol.style.Style({
              stroke: new ol.style.Stroke({
                color: 'red',
                width: 2
              }),
              fill: new ol.style.Fill({
                color: 'rgba(255,0,0,0.2)'
              })
            })
          };
        return styles[selected.getGeometry().getType()];
      } else {
        return new ol.style.Style({
          image: new ol.style.Icon({
            anchor: [0.5, 1],
            anchorXUnits: 'fraction',
            anchorYUnits: 'fraction',
            src: '/_common/themes/openlayers/images/marker-blue.png'
          })
         });
      }
    });

    this._map_canvas.addLayer(this._vector_layers[options.name]);
  }

}

OpenLayersPortalViewer.prototype.set_selector = function(){
  var layers = [];
  for (key in this._vector_layers) {
    layers.push(this._vector_layers[key]);
  }

  this._select_feature = new ol.interaction.Select({layers: layers});
  this._map_canvas.addInteraction(this._select_feature);

  var _this = this;
  this._select_feature.on('select', function(e) {
    var selectedFeatures = e.selected[0].getProperties().features;
    var nearbyMarkers = [];
    for(let i = 0; i < selectedFeatures.length; i++) {
      var selected = selectedFeatures[i];
      var coordinate = selected.getGeometry().getCoordinates();
      if( i == 0 ){
        var markerId = selected.get('id');
        var url      = selected.get('url');
      } else {
        nearbyMarkers.push(selected.get('id'));
      }
    }
    _this.display_featureInfo(_this, coordinate, markerId, url, nearbyMarkers);
  });
}

OpenLayersPortalViewer.prototype.display_featureInfo = function(_this, coordinate, markerId, url, nearbyMarkers){
  if ( nearbyMarkers.length > 0) {
    var nearIds = nearbyMarkers.join('&names[]=');
    url = url + '?names[]=' + nearIds;
  }
  $.get(url, function(result) {
    var dom = $.parseHTML(result);
    _this._content.innerHTML = dom[0].data;
    _this._popoverlay.setPosition(coordinate);
    _this._select_feature.getFeatures().clear();
  });
}

OpenLayersPortalViewer.prototype.toggle_layer = function(name, visible){
  if ( this._vector_layers[name] != null ){
    this._vector_layers[name].setVisible(visible);
  }
}