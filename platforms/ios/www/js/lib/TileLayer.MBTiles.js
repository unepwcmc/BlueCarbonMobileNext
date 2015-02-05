/**
 * Leaflet TileLayer extension for displaying tiles stored
 * in the .mbtiles format.
 */
L.TileLayer.MBTiles = L.TileLayer.extend({
  initialize: function(db, options) {
    this.db = db;
    L.Util.setOptions(this, options);
  },

  _loadTile: function(tile, tilePoint) {
    this._adjustTilePoint(tilePoint);

    tile._layer = this;
    tile.onload = this._tileOnLoad;
    tile.onerror = this._tileOnError;

    var z = this._getZoomForUrl();
    var x = tilePoint.x;
    var y = tilePoint.y;
    tile.src = "res/tiles/transparent.png";

    this.db.transaction(function(tx) {
      tx.executeSql(
        "SELECT tile_data FROM images " +
        "INNER JOIN map ON images.tile_id = map.tile_id " +
        "WHERE zoom_level = ? " +
        "AND tile_column = ? " +
        "AND tile_row = ?",
        [z, x, y],
        function (tx, res) {
          if (res.rows.length > 0) {
            tile.src = "data:image/png;base64," + res.rows.item(0).tile_data;
          }
        },
        function (er) {
          console.log('Database Error');
          console.log(er);
        }
      );
    });
  }
});
