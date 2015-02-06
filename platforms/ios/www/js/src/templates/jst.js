// Generated by CoffeeScript 1.7.1
(function() {
  window.JST = {};

  window.JST['area/edit'] = _.template("<div class='ios-head'>\n  <a class='back'>Back</a>\n  <h2><%= area.get('title') %></h2>\n</div>\n<a id=\"new-validation\" class=\"btn btn-large\">New Validation</a>\n<ul id='validation-list'></ul>\n<% if (uploading) { %>\n  <div id='uploading-validations'>\n    <img src=\"css/images/timerV2.gif\"/>\n    Uploading Validations...\n  </div>\n<% } else if (validationCount > 0) { %>\n  <a id=\"upload-validations\" class=\"btn\">\n    <span>Upload Validations</span>\n    <img src=\"css/images/upload.png\"/>\n  </a>\n<% } %>");

  window.JST['area/add_polygon'] = _.template("<div class='ios-head'>\n  <a class='back'>Area</a>\n  <h2>Add Validation</h3>\n</div>\n<div id='draw-polygon-notice'>\n  Draw your polygon by tapping on the map\n</div>\n<form id=\"validation-attributes\" onSubmit=\"return false;\">\n  <input type='hidden' name='area_id' value=\"<%= area.get('id') %>\"/>\n  <input type='hidden' name='recorded_at' value=\"<%= date %>\"/>\n  <ul class=\"fields\">\n    <li>\n      <label>Habitat</label>\n      <select name=\"habitat\">\n        <option value=\"\">Select a habitat layer</option>\n        <option value=\"mangrove\">Mangrove</option>\n        <option value=\"seagrass\">Seagrass</option>\n        <option value=\"saltmarsh\">Salt Marsh</option>\n        <option value=\"sabkha\">Sabkha</option>\n        <option value=\"algal_mat\">Algal Mat</option>\n        <option value=\"other\">Other</option>\n      </select>\n    </li>\n    <li>\n      <label>Validation Type</label>\n      <select name=\"action\">\n        <option value=\"\">Select Validation Type</option>\n        <option value=\"add\">Add</option>\n        <option value=\"delete\">Delete</option>\n      </select>\n    </li>\n    <div id='validation-details'>\n      <li class=\"conditional seagrass mangrove saltmarsh\">\n        <label>Density</label>\n        <select name=\"density\">\n          <option value=\"\">Unknown</option>\n          <option value=\"1\">Sparse (<20% cover)</option>\n          <option value=\"2\">Moderate (20-50% cover)</option>\n          <option value=\"3\">Dense (50-80% cover)</option>\n          <option value=\"4\">Very dense (>80% cover)</option>\n        </select>\n      </li>\n      <li class=\"conditional mangrove\">\n        <label>Condition</label>\n        <select name=\"condition\">\n          <option value=\"1\">Undisturbed / Intact</option>\n          <option value=\"2\">Degraded</option>\n          <option value=\"3\">Restored / Rehabilitating</option>\n          <option value=\"4\">Afforested/ Created</option>\n          <option value=\"5\">Cleared</option>\n        </select>\n      </li>\n      <li class=\"conditional mangrove\">\n        <label>Age</label>\n        <select name=\"age\">\n          <option value=\"\">Unknown</option>\n          <option value=\"1\">Natural Mangrove</option>\n          <option value=\"2\">2-10 yrs old</option>\n          <option value=\"3\">10-25 yrs old</option>\n          <option value=\"4\">25-50 yrs old</option>\n        </select>\n      </li>\n      <li class=\"conditional seagrass\">\n        <label>Species</label>\n        <select name=\"species\">\n          <option value=\"\">Unknown</option>\n          <option value=\"Halodule uninervis\">Halodule uninervis</option>\n          <option value=\"Halophila ovalis\">Halophila ovalis</option>\n          <option value=\"Halophila stipulacea\">Halophila stipulacea</option>\n          <option value=\"Mixed species\">Mixed species</option>\n        </select>\n      </li>\n      <li>\n        <label>Notes</label>\n        <textarea name=\"notes\"></textarea>\n      </li>\n    </div>\n  </ul>\n  <a id=\"create-analysis\" class=\"btn btn-large\">Save</a>\n</form>");

  window.JST['area/login'] = _.template("<h3>Please sign in</h3>\n<div class='error'></div>\n<form id=\"login-form\" onSubmit=\"return false;\">\n  <ul class=\"fields\">\n    <li>\n      <label>Email</label>\n      <input type=\"email\" name=\"email\" id=\"username\">\n    </li>\n    <li>\n      <label>Password</label>\n      <input name=\"password\" id=\"password\" type=\"password\">\n    </li>\n  </ul>\n  <a id=\"login\" class='btn'>Sign In</a> <img src=\"css/images/timer.gif\" class=\"loading-spinner\" />\n</form>");

  window.JST['area/area_index'] = _.template("<div class='ios-head'>\n  <h2>Field Sites</h2>\n</div>\n<div id=\"sync-info\">\n  <span id=\"sync-status\"></span>\n  <a class=\"sync-areas btn btn-small\">\n    <img src=\"css/images/sync.png\"/>\n    Sync\n  </a>\n</div>\n<ul id=\"area-list\">\n</ul>");

  window.JST['area/area'] = _.template("<div class='area-attributes'>\n  <h3><%= area.get('title') %></h3>\n  <p>\n    <%\n    var downloadState = area.downloadState();\n    if (downloadState === 'out of date') {\n    %>\n      Habitat data is out of date\n    <% } else if (downloadState === 'no data') { %>\n      Habitat data not yet downloaded\n    <% } else { %>\n      Data downloaded at: <%= area.lastDownloaded() %>\n    <% } %>\n  </p>\n</div>\n<% if (false || downloadState === 'ready') { %>\n  <div class=\"area-actions start-trip\">\n    <img src=\"css/images/arrow_forward.png\"/>\n    <div>START TRIP</div>\n  </div>\n<% } else if (downloadState === 'out of date' || downloadState === 'no data') { %>\n  <div class=\"area-actions download-data\">\n    <img src=\"css/images/download_icon.png\"/>\n    <div>DOWNLOAD</div>\n  </div>\n<% } else if (downloadState === 'data generating') { %>\n  <div class='area-actions data-generating'>\n    <div class=\"loader\"></div>\n    <div>GENERATING</div>\n  </div>\n<% } else if (downloadState === 'downloading') { %>\n  <div class='area-actions data-downloading'>\n    <img src=\"css/images/timer.gif\"/>\n    <div>DOWNLOADING</div>\n  </div>\n<% } %>");

  window.JST['area/validation'] = _.template("<span class=\"validation-title\">\n  <%= validation.name() %>\n</span>\n<img class='delete-validation' src=\"css/images/trash_can.png\"/>\n<table class=\"validation-details\">\n  <tr>\n    <th>Habitat</th>\n    <td><%= humanAttributes.habitat %></td>\n  </tr>\n  <tr>\n    <th>Action</th>\n    <td><%= humanAttributes.action %></td>\n  </tr>\n  <% if (typeof humanAttributes.density !== 'undefined') {%>\n    <tr>\n      <th>Density</th>\n      <td><%= humanAttributes.density %></td>\n    </tr>\n  <% } %>\n  <% if (typeof humanAttributes.condition !== 'undefined') {%>\n    <tr>\n      <th>Condition</th>\n      <td><%= humanAttributes.condition %></td>\n    </tr>\n  <% } %>\n  <% if (typeof humanAttributes.age !== 'undefined') {%>\n    <tr>\n      <th>Age</th>\n      <td><%= humanAttributes.age %></td>\n    </tr>\n  <% } %>\n  <% if (typeof humanAttributes.species !== 'undefined') {%>\n    <tr>\n      <th>Species</th>\n      <td><%= humanAttributes.species %></td>\n    </tr>\n  <% } %>\n  <% if (typeof humanAttributes.notes !== 'undefined') {%>\n    <tr>\n      <th>Notes</th>\n      <td><%= humanAttributes.notes %></td>\n    </tr>\n  <% } %>\n</table>");

}).call(this);
