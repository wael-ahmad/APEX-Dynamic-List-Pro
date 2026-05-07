# Dynamic Text List Plugin for Oracle APEX

A powerful, drag & drop enabled multi-value input plugin for Oracle APEX that supports JSON/SQL data sources, validation, and AJAX refresh.

![APEX](https://img.shields.io/badge/APEX-22.2%2B-blue)
![License](https://img.shields.io/badge/License-MIT-green.svg)
![Version](https://img.shields.io/badge/version-1.0.0-orange)

---

## 🚀 Features

- ✅ Multi-value input (email, phone, tags, etc.)
- 🖱️ Drag & Drop reordering with intuitive UX
- 📊 JSON & SQL data sources support
- 🔍 Validation rules (Email, Phone, Custom Regex)
- 🔄 Duplicate detection & prevention
- ⚡ AJAX refresh support (e.g., cascade selects)
- 🎨 Native APEX theme integration

---

## 🎯 Use Cases

| Use Case | Description |
|----------|-------------|
| 📞 Multiple phone numbers | Store multiple contacts per customer |
| 🚌 Ordered lists | Passenger lists, agenda items, priority rankings |
| 🏷️ Tags input | Blog categories, product keywords |
| ✅ Dynamic selection lists | Preference ranking, survey options |

---

## 📸 Demo Application

Try the live demo application to explore the plugin features:

  <a href="https://oracleapex.com/ords/r/wael_plugins/apex-dynamic-list-pro" target="_blank" rel="noopener noreferrer">
    <img src="https://img.shields.io/badge/🚀_Live_Demo-Try_It_Now-2c9c8c?style=for-the-badge&logo=oracle&logoColor=white" alt="Live Demo">
  </a>

---

## ⚙️ Installation

### Step 1: Import Plugin
- Navigate to **Shared Components** → **Plug-ins**
- Click **Import** and select `plugin.sql`
- Click **Install**

### Step 2: Create Page Item
- Go to Page Designer
- Add a new **Page Item**
- Set **Type** → `Dynamic Text List [Plug-in]`

### Step 3: Configure Attributes
| Attribute | Recommended Value |
|-----------|-------------------|
| Item Template | `-- Select --` (NULL for best display) |
| Data Source | JSON / SQL Query |
| Validation | Email / Phone / Regex |

---

## 🔄 AJAX Refresh Example

### Scenario: Refresh list when class ID changes

**Dynamic Action Settings:**

| Property | Value |
|----------|-------|
| Event | Change |
| Selection Type | Item(s) |
| Item | `P1_CLASS_ID` |
| Action | Execute JavaScript |

**JavaScript Code:**
```javascript
apex.dtl_reorder.refresh("P1_ITEM");
```
