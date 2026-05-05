apex.dtl_input = (function () {

    function init(pItemId, options) {
        var core = apex.dynamicCore;
        core.debug = (options.jsLogEnabled === "Y");
        core.log("INIT", pItemId, options);

        var container = document.getElementById(pItemId + "_container");
        var hidden = document.getElementById(pItemId);

        if (!container || !hidden) {
            core.error("Container/Hidden not found", pItemId);
            return;
        }

        /* =========================
           Config
        ========================= */
        var maxItems = options.maxItems || 999;
        var initialCount = options.initialCount || 1;
        var btnsPos = options.btns_pos || "E";
        var btnsStyle = options.btns_style || "D";
        var mType  = options.m_type || "D";
        var separator = options.separator || ":";
        var validationType = options.validationType || "N";
        var regex = options.regex;
        var allowDuplicates = (options.allowDuplicates === "Y");

        /* =========================
           Helpers
        ========================= */
        function validate(val) {
            return core.validateValue(val, validationType, regex);
        }

        /* =========================
           Row Creation
        ========================= */

        function createRow(value) {
            
            var row = document.createElement("div");
            row.className = "dtl-row t-Form-inputContainer";

            var input = document.createElement("input");
            input.type = "text";
            input.className = "text_field apex-item-text";
            input.value = value || "";
            input.size = "30";

            var removeBtn = document.createElement("button");
            removeBtn.type = "button";
            removeBtn.className = (btnsStyle === "D")
                ? "t-Button t-Button--noUI t-Button--icon dtl-remove"
                : "t-Button t-Button--icon dtl-remove t-Button--danger";

            removeBtn.innerHTML = '<span class="fa fa-times"></span>';

            removeBtn.onclick = function () {
                try {
                    row.remove();
                    refresh();

                    core.triggerEvent(hidden, "row_deleted", {
                        count: container.children.length,
                        item: pItemId
                    });

                    core.log("Row deleted");

                } catch (e) {
                    core.error("Remove error", e);
                }
            };

            var addBtn = document.createElement("button");
            addBtn.type = "button";
            addBtn.className = (btnsStyle === "D")
                ? "t-Button t-Button--noUI t-Button--icon dtl-add"
                : "t-Button t-Button--icon dtl-add t-Button--primary";

            addBtn.innerHTML = '<span class="fa fa-plus"></span>';

            addBtn.onclick = function () {
                try {

                    if (container.children.length >= maxItems) {
                        core.triggerEvent(hidden, "max_rows_reached", {
                            max: maxItems
                        });

                        core.log("Max rows reached");
                        return;
                    }

                    if (!validate(input.value)) {
                        input.classList.add("dtl-error");

                        core.triggerEvent(hidden, "validation_failed", {
                            value: input.value,
                            item: pItemId
                        });

                        return;
                    } else {
                        input.classList.remove("dtl-error");
                    }

                    var newRow = createRow("");
                    container.appendChild(newRow);

                    refresh();

                    core.triggerEvent(hidden, "row_added", {
                        count: container.children.length,
                        item: pItemId
                    });

                    newRow.querySelector("input").focus();

                } catch (e) {
                    core.error("Add error", e);
                }
            };

            if (btnsPos === "S") {
                row.appendChild(removeBtn);
                row.appendChild(addBtn);
                row.appendChild(input);
            } else {
                row.appendChild(input);
                row.appendChild(removeBtn);
                row.appendChild(addBtn);
            }

            /* Events */
            input.addEventListener("input",
                core.debounce(refresh, 300)
            );

            input.addEventListener("keydown", function (e) {
                if (e.key === "Enter") {
                    e.preventDefault();
                    addBtn.click();
                }
            });

            return row;
        }

        /* =========================
           Refresh
        ========================= */

        function refresh() {
            try {
                var rows = container.querySelectorAll(".dtl-row");

                var values = [];
                var seen = new Set();
                var hasDuplicates = false;

                rows.forEach(function (row) {

                    var input = row.querySelector("input");
                    var val = input.value.trim();

                    // Validation UI
                    if (!validate(val)) {
                        input.classList.add("dtl-error");
                    } else {
                        input.classList.remove("dtl-error");
                    }

                    // Duplicate detection
                    if (!allowDuplicates && val !== "" && seen.has(val)) {
                        row.classList.add("dtl-duplicate");
                        hasDuplicates = true;
                    } else {
                        row.classList.remove("dtl-duplicate");
                    }

                    if (val !== "") {
                        values.push(val);
                    }

                    seen.add(val);
                });

                var finalValue = (mType === "J")
                    ? JSON.stringify(values)
                    : values.join(separator);

                apex.item(pItemId).setValue(finalValue);

                // Buttons control
                rows.forEach(function (row, index) {
                    var removeBtn = row.querySelector(".dtl-remove");
                    var addBtn = row.querySelector(".dtl-add");

                    removeBtn.style.display =
                        (rows.length === 1) ? "none" : "inline-block";

                    addBtn.style.display =
                        (index === rows.length - 1 && rows.length < maxItems)
                            ? "inline-block"
                            : "none";
                });

                core.triggerEvent(hidden, "value_changed", {
                    values: values,
                    item: pItemId
                });

                if (hasDuplicates) {
                    core.triggerEvent(hidden, "duplicates_found", {
                        item: pItemId
                    });
                }

                core.log("Refresh complete", values);

            } catch (e) {
                core.error("Refresh error", e);
            }
        }

         /* =========================
           Init Rows
        ========================= */
        function initRows() {

            try {
                var existing = [];

                if (hidden.value) {
                    existing = (mType === "J")
                        ? core.safeJSON(hidden.value, [])
                        : hidden.value.split(separator);
                }

                if (existing.length > 0) {
                    existing.forEach(function (val) {
                        container.appendChild(createRow(val));
                    });
                } else {
                    for (var i = 0; i < initialCount; i++) {
                        container.appendChild(createRow(""));
                    }
                }

                refresh();

                core.log("Initialized", existing);

            } catch (e) {
                core.error("Init error", e);
            }
        }

        /* =========================
           Init
        ========================= */
        initRows();
    }

    return {
        init: init
    };

})();

apex.dtl_reorder = (function () {

    function init(pItemId, options) {

        var core = apex.dynamicCore;
        core.debug = (options.jsLogEnabled === "Y");
        core.log("INIT", pItemId, options);

        var container = document.getElementById(pItemId + "_container");
        var hidden = document.getElementById(pItemId);

        if (!container || !hidden) {
            core.error("Container or hidden not found", pItemId);
            return;
        }

        hidden._dtl_options = options;

        var sortableInstance = null;

        /* =========================
           UI Helpers
        ========================= */

        function showError(msg) {
            container.innerHTML = `
                <div class="t-Alert t-Alert--danger">
                    ${msg || "Error loading data"}
                </div>
            `;
        }

        function showEmpty() {
            var empty = document.createElement("div");
            var emptyText = options.noDataFound || "No data found";
            empty.className = "t-Alert t-Alert--defaultIcons t-Alert--warning t-Alert--horizontal";

            empty.innerHTML = `
                <div class="t-Alert-wrap">
                    <div class="t-Alert-icon">
                        <span class="t-Icon fa-info-circle"></span>
                    </div>
                    <div class="t-Alert-content">
                        <div class="t-Alert-body">
                            ${emptyText}
                        </div>
                    </div>
                </div>
            `;
            container.appendChild(empty);
        }

        /* =========================
           Row Creation
        ========================= */

        function createRow(obj) {

            try {

                var row = document.createElement("div");
                row.className = "dtl-row t-Form-inputContainer";
                row.dataset.id = obj.id;

                var handle = document.createElement("span");
                handle.className = "fa fa-bars dtl-handle";

                var input = document.createElement("input");
                input.type = "text";
                input.className = "text_field apex-item-text";
                input.value = obj.label || "";
                input.readOnly = true;

                row.appendChild(handle);
                row.appendChild(input);

                return row;

            } catch (e) {
                core.error("createRow failed", e, obj);
                return document.createElement("div");
            }
        }

        /* =========================
           Values
        ========================= */
        function getValues() {
            try {
                var rows = container.querySelectorAll(".dtl-row");
                var values = [];

                rows.forEach(function (row) {
                    values.push({
                        id: row.dataset.id,
                        label: row.querySelector("input").value
                    });
                });

                return values;

            } catch (e) {
                core.error("getValues failed", e);
                return [];
            }
        }

        function setValue(values) {
            try {
                apex.item(pItemId).setValue(JSON.stringify(values));
            } catch (e) {
                core.error("setValue failed", e);
            }
        }

        function refreshValue() {
            setValue(getValues());
        }

        /* =========================
           Rendering
        ========================= */

        function renderList(data) {

            core.log("Render list", data);

            container.innerHTML = "";

            if (!data || data.length === 0) {
                showEmpty();
                setValue([]);
                return;
            }

            try {
                data.forEach(function (obj) {
                    container.appendChild(createRow(obj));
                });

                setValue(getValues());

            } catch (e) {
                core.error("renderList failed", e);
                showError();
            }
        }

        /* =========================
           Drag & Drop
        ========================= */
        function enableDragDrop() {

            if (typeof Sortable === "undefined") {
                core.error("SortableJS not loaded");
                return;
            }

            if (sortableInstance) return;

            try {

                sortableInstance = new Sortable(container, {
                    animation: 150,
                    handle: ".dtl-handle",
                    ghostClass: "dtl-drag-ghost",

                    onEnd: function () {

                        var values = getValues();

                        setValue(values);

                        core.triggerEvent(hidden, "row_reordered", {
                            values: values,
                            item: pItemId
                        });
                    }
                });

            } catch (e) {
                core.error("Sortable init failed", e);
            }
        }

        /* =========================
           AJAX Refresh
        ========================= */
        function ajaxRefresh() {

            if (!options.ajaxIdentifier) {
                core.log("No AJAX identifier, skipping refresh");
                return;
            }

            core.log("AJAX CALL", options);

            var spinner;

            try {
                spinner = apex.util.showSpinner(container);
                container.style.pointerEvents = "none";
                container.style.opacity = "0.5";
            } catch (e) {
                core.error("Spinner failed", e);
            }

            apex.server.plugin(
                options.ajaxIdentifier,
                {
                    pageItems: (options.pageItems || "")
                        .split(",")
                        .map(function (i) { return "#" + i.trim(); })
                        .join(",")
                },
                {
                    success: function (res) {

                        core.log("AJAX SUCCESS", res);

                        try {

                            var data = core.safeJSON(res.data, []);

                            renderList(data);

                            core.triggerEvent(hidden, "data_refreshed", {
                                count: data.length,
                                item: pItemId
                            });

                        } catch (e) {
                            core.error("AJAX success processing failed", e);
                            showError("Invalid data");
                        }

                        cleanup();
                    },

                    error: function (err) {

                        core.error("AJAX ERROR", err);

                        showError("Failed to load data");

                        cleanup();
                    }
                }
            );

            function cleanup() {
                try {
                    if (spinner) spinner.remove();
                    container.style.pointerEvents = "auto";
                    container.style.opacity = "1";
                } catch (e) {
                    core.error("Cleanup failed", e);
                }
            }
        }

        /* =========================
           Init
        ========================= */
        function initRows() {

            try {

                var data = core.safeJSON(options.sourceData, []);

                // fallback
                if ((!data || data.length === 0) && hidden.value) {
                    data = core.safeJSON(hidden.value, []);
                }

                renderList(data);

            } catch (e) {
                core.error("initRows failed", e);
                showError();
            }
        }

        initRows();
        enableDragDrop();

        hidden._dtl_refresh = ajaxRefresh;
    }

    /* =========================
       Public API
    ========================= */
    return {

        init: init,

        refresh: function (pItemId) {

            var el = document.getElementById(pItemId);

            if (el && el._dtl_refresh) {
                el._dtl_refresh();
            } else {
                console.warn("DTL: refresh not initialized", pItemId);
            }
        }

    };

})();


apex.dynamicCore = {

    debug: true, 

    log: function () {
        if (this.debug) {
            console.log.apply(console, ["DTL:"].concat(Array.from(arguments)));
        }
    },

    error: function () {
        console.error.apply(console, ["DTL ERROR:"].concat(Array.from(arguments)));
    },

    debounce: function (fn, delay) {
        let timer;
        return function () {
            clearTimeout(timer);
            timer = setTimeout(fn, delay);
        };
    },

    triggerEvent: function (el, name, data) {
        try {
            apex.event.trigger(el, name, data || {});
        } catch (e) {
            this.error("Event trigger failed", name, e);
        }
    },

    safeJSON: function (val, fallback) {
        try {
            return typeof val === "string" ? JSON.parse(val) : val;
        } catch (e) {
            this.error("JSON parse failed", val, e);
            return fallback || [];
        }
    },
    validateValue: function(val, v_type, v_regex){
        if (v_type === "E") {
            return /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(val);
        }

        if (v_type === "P") {
            return /^[0-9+\-\s]+$/.test(val);
        }

        if (v_type === "R") {
            return new RegExp(v_regex).test(val);
        }

        return true;
    }

};
