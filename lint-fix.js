var priorities = {
    error: 0,
    warning: 1,
    "1": 2,
    "2": 3,
    "3": 4
};

function mapPriority(str) {
    "use strict";
    var value = priorities[str];
    if (undefined === value) {
        console.log("invalid priority:" + str);
        return 5;
    }
    return value;
}

$(document).ready(function() {
    "use strict";
    var rows = []; //[{priority:"1", html:""}];
    var rules = [];
    var rulesInfo = {};


    $("body > table:nth-child(6) > thead > tr")[0].cells[1].remove()
    $("body > table:nth-child(6) > tbody > tr").each(function() {
        var item = $(this);
        var fields = $("td", item);

        var pathItem = $(fields[0]);
        var path = pathItem.text().replace(/^\/.*\//g, "");

        var locationItem = $(fields[1]);
        var location = locationItem.text().trim();

        var ruleName = $(fields[2]).text().trim();

        var ruleCategory = $(fields[3]).text().trim();

        var priorityText = $(fields[4]).text().trim();
        var priority = mapPriority(priorityText.trim());

        var message = $(fields[5]).text()
            /// $0 是特殊的设计模式
        if (message.search("$0") != -1) {
            return;
        }

        if (rules.indexOf(ruleName) == -1) {
            rules.push(ruleName);
        }
        if (rulesInfo[ruleName] == undefined) {
            rulesInfo[ruleName] = {
                name: ruleName,
                count: 0,
                priority: priority
            };
        }
        rulesInfo[ruleName].count += 1;

        if (rulesInfo["All"] == undefined) {
            rulesInfo["All"] = {
                name: "All",
                count: 0,
                priority: priority
            };
        }
        rulesInfo["All"].count += 1;

        rows.push({
            location: path + ":" + location,
            ruleName: ruleName,
            ruleCategory: ruleCategory,
            priority: priority,
            message: message
        });
    });

    rows = rows.sort(function(a, b) {
        if (a.priority > b.priority) {
            return 1;
        }
        if (a.priority < b.priority) {
            return -1;
        }
        return 0;
    });

    var htmls = "";
    rows.forEach(function(value) {
        htmls +=
            "<tr><td>" + value.location + "</td><td>" + value.ruleName + "</td><td>" + value.ruleCategory + "</td><td class='priority2'>" + value.priority + "</td><td>" + value.message + "</td></tr>";
    });

    $("body > table:nth-child(6) > tbody").html(htmls);

    rules = rules.sort(function(a, b) {
        var p1 = rulesInfo[a].priority;
        var p2 = rulesInfo[b].priority
        if (p1 > p2) {
            return 1;
        }
        if (p1 < p2) {
            return -1;
        }
        return 0;
    });
    rules.unshift("All");

    var optionHtmls = ""
    rules.forEach(function(value) {
        optionHtmls += " <option value=\"" + value + "\"> " + value + "(" + rulesInfo[value].count + ")"; + "</option>";
    });

    var selectHtml = "<div style='margin:10px 0px;'> <span id='rules-catalog'>rules</span>:" + " <select id='select' style='height: 20px;-webkit-border-radius: 0;border: 0; outline: 1px solid #ccc;outline-offset: -1px;'>" + optionHtmls + "</select></div>";

    $(selectHtml).insertBefore($("body>hr")[1]);

    $("#select").change(function() {
        $("select option:selected").each(function() {
            var ruleName = $(this).text().trim();
            var htmls = "";
            if (ruleName.search("All") != -1) {
                rows.forEach(function(value) {
                    htmls +=
                        "<tr><td>" + value.location + "</td><td>" + value.ruleName + "</td><td>" + value.ruleCategory + "</td><td class='priority2'>" + value.priority + "</td><td>" + value.message + "</td></tr>";
                });
            } else {
                rows.forEach(function(value) {
                    if (ruleName.search(value.ruleName) != -1) {
                        htmls +=
                            "<tr><td>" + value.location + "</td><td>" + value.ruleName + "</td><td>" + value.ruleCategory + "</td><td class='priority2'>" + value.priority + "</td><td>" + value.message + "</td></tr>";
                    }
                });
            }
            ///var rulesText = "rules(" + rulesInfo[ruleName] + ")";
            $("body > table:nth-child(7) > tbody").html(htmls);
            // $("#rules-catalog").text(rulesText);
        });
    }).change();
});
