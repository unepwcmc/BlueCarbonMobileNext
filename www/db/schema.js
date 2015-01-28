/*
 * # Temporary Schema Management
 *
 * Run with `node db/schema.js`
 *
 */

var tables = {
  "validation": {
    "name": "TEXT",
    "user_id": "INTEGER",
    "points": "TEXT",
    "created_at": "TEXT"
  }
};


for (var table in tables) {
  var sql = [];
  sql.push("CREATE TABLE IF NOT EXISTS " + table + " (");

  for (var field in tables[table]) {
    sql.push(field + " " + tables[table][field] + ",");
  }

  sql.push(")");

  sql = sql.join(" ");

  // Remove trailing comma
  sql = sql.replace(/,\s+\)/, ")");

  console.log(sql);
}
