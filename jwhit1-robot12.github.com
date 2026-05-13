
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<style>
  @import url('https://fonts.googleapis.com/css2?family=Cinzel:wght@400;600;700;900&family=Exo+2:wght@300;400;500;600;700&family=Share+Tech+Mono&display=swap');

  *, *::before, *::after { box-sizing: border-box; margin: 0; padding: 0; }

  :root {
    --bg: #080a0f;
    --bg2: #0c0f18;
    --bg3: #111520;
    --bg4: #161c2c;
    --border: rgba(168,124,255,0.12);
    --border2: rgba(168,124,255,0.28);
    --accent: #a87cff;
    --accent2: #8b5cf6;
    --accent3: #c4b0ff;
    --gold: #f0c040;
    --gold2: #ffd966;
    --gold3: rgba(240,192,64,0.15);
    --red: #ff6b6b;
    --green: #4ade80;
    --text: #e8e4f0;
    --text2: #a89cc0;
    --text3: #5a5470;
    --font-head: 'Cinzel', serif;
    --font-body: 'Exo 2', sans-serif;
    --font-mono: 'Share Tech Mono', monospace;
  }

  body { background: var(--bg); color: var(--text); font-family: var(--font-body); min-height: 600px; font-size: 14px; line-height: 1.5; }

  .header {
    background: var(--bg2); border-bottom: 1px solid var(--border2);
    padding: 0 20px; display: flex; align-items: center; justify-content: space-between;
    height: 58px; position: sticky; top: 0; z-index: 100;
  }
  .header::after {
    content: ''; position: absolute; bottom: -2px; left: 0; right: 0;
    height: 1px; background: linear-gradient(90deg, transparent, var(--gold), transparent); opacity: 0.4;
  }
  .header-brand { display: flex; align-items: center; gap: 12px; }
  .brand-badge { background: var(--gold); color: #1a0f00; font-family: var(--font-head); font-size: 16px; font-weight: 900; padding: 3px 11px; letter-spacing: 1px; }
  .brand-col { display: flex; flex-direction: column; gap: 1px; }
  .brand-name { font-family: var(--font-head); font-size: 17px; font-weight: 700; color: var(--gold2); letter-spacing: 2px; line-height: 1.1; }
  .brand-sub { font-family: var(--font-mono); font-size: 9px; color: var(--text3); letter-spacing: 2px; text-transform: uppercase; }
  .nav-tabs { display: flex; gap: 2px; }
  .nav-tab { font-family: var(--font-head); font-size: 11px; font-weight: 600; letter-spacing: 1.5px; text-transform: uppercase; padding: 6px 16px; border: none; background: transparent; color: var(--text3); cursor: pointer; border-bottom: 2px solid transparent; transition: all 0.2s; }
  .nav-tab:hover { color: var(--text2); }
  .nav-tab.active { color: var(--accent3); border-bottom-color: var(--accent); }
  .nav-tab.admin-locked { color: var(--text3); }
  .nav-tab.admin-unlocked { color: var(--gold); }
  .header-right { display: flex; align-items: center; gap: 10px; }
  .admin-status { font-family: var(--font-mono); font-size: 10px; padding: 3px 10px; border-radius: 2px; border: 1px solid; letter-spacing: 1px; }
  .admin-status.locked { color: var(--text3); border-color: var(--text3); }
  .admin-status.unlocked { color: var(--gold); border-color: var(--gold); background: var(--gold3); }
  .btn-sm { font-family: var(--font-head); font-size: 11px; font-weight: 600; letter-spacing: 1px; padding: 5px 13px; border: 1px solid var(--border2); background: transparent; color: var(--text2); cursor: pointer; transition: all 0.2s; }
  .btn-sm:hover { border-color: var(--accent); color: var(--accent); }

  .page { display: none; padding: 22px; min-height: 540px; max-height: 580px; overflow-y: auto; }
  .page.active { display: block; }
  .page::-webkit-scrollbar { width: 4px; }
  .page::-webkit-scrollbar-track { background: var(--bg2); }
  .page::-webkit-scrollbar-thumb { background: var(--border2); border-radius: 2px; }

  .modal-overlay { display: none; position: fixed; inset: 0; background: rgba(0,0,0,0.82); z-index: 200; align-items: center; justify-content: center; }
  .modal-box { background: var(--bg2); border: 1px solid var(--border2); border-top: 2px solid var(--gold); padding: 32px; width: 300px; text-align: center; }
  .modal-title { font-family: var(--font-head); font-size: 16px; color: var(--gold2); letter-spacing: 3px; margin-bottom: 6px; }
  .modal-sub { font-family: var(--font-mono); font-size: 10px; color: var(--text3); letter-spacing: 2px; margin-bottom: 20px; }
  .lock-input { background: var(--bg3); border: 1px solid var(--border2); color: var(--text); font-family: var(--font-mono); font-size: 20px; text-align: center; letter-spacing: 6px; padding: 10px 20px; width: 100%; outline: none; margin-bottom: 4px; }
  .lock-input:focus { border-color: var(--accent); }
  .lock-err { color: var(--red); font-family: var(--font-mono); font-size: 11px; height: 16px; margin: 6px 0; }
  .modal-btns { display: flex; gap: 8px; margin-top: 10px; }
  .btn-gold { flex: 1; background: var(--gold); border: none; color: #1a0f00; font-family: var(--font-head); font-size: 12px; font-weight: 700; letter-spacing: 2px; padding: 9px; cursor: pointer; transition: background 0.2s; }
  .btn-gold:hover { background: var(--gold2); }
  .btn-ghost { flex: 1; background: transparent; border: 1px solid var(--border2); color: var(--text2); font-family: var(--font-head); font-size: 11px; letter-spacing: 1px; padding: 9px; cursor: pointer; }

  .section-head { display: flex; align-items: flex-start; gap: 12px; margin-bottom: 20px; }
  .section-head-bar { width: 3px; background: var(--gold); align-self: stretch; flex-shrink: 0; min-height: 36px; }
  .section-title { font-family: var(--font-head); font-size: 20px; font-weight: 700; color: var(--gold2); letter-spacing: 3px; text-transform: uppercase; }
  .section-sub { font-family: var(--font-mono); font-size: 10px; color: var(--text3); letter-spacing: 1.5px; margin-top: 2px; }

  .form-grid { display: grid; grid-template-columns: 1fr 1fr; gap: 14px; margin-bottom: 18px; }
  .form-group { display: flex; flex-direction: column; gap: 5px; }
  .form-group.full { grid-column: 1/-1; }
  .form-label { font-family: var(--font-mono); font-size: 10px; color: var(--text3); letter-spacing: 1.5px; text-transform: uppercase; }
  .form-input, .form-select, .form-textarea { background: var(--bg3); border: 1px solid var(--border); color: var(--text); font-family: var(--font-body); font-size: 13px; padding: 8px 11px; outline: none; transition: border-color 0.2s; }
  .form-input:focus, .form-select:focus, .form-textarea:focus { border-color: var(--accent2); }
  .form-select option { background: var(--bg3); }
  .form-textarea { resize: vertical; min-height: 68px; }

  /* Scout form event key display */
  .event-key-badge {
    display: inline-flex; align-items: center; gap: 8px;
    background: var(--bg3); border: 1px solid var(--border2);
    padding: 6px 14px; margin-bottom: 18px;
  }
  .event-key-label { font-family: var(--font-mono); font-size: 10px; color: var(--text3); letter-spacing: 1.5px; text-transform: uppercase; }
  .event-key-val { font-family: var(--font-mono); font-size: 13px; color: var(--gold2); letter-spacing: 1px; }
  .event-key-none { font-family: var(--font-mono); font-size: 11px; color: var(--red); letter-spacing: 1px; }

  .ratings-block { background: var(--bg3); border: 1px solid var(--border); border-left: 3px solid var(--accent2); padding: 16px; margin-bottom: 16px; }
  .ratings-title { font-family: var(--font-head); font-size: 12px; font-weight: 600; color: var(--accent3); margin-bottom: 14px; letter-spacing: 2px; text-transform: uppercase; }
  .rating-row { display: flex; align-items: center; gap: 10px; margin-bottom: 9px; }
  .rating-label { font-family: var(--font-mono); font-size: 10px; color: var(--text3); width: 140px; flex-shrink: 0; letter-spacing: 1px; text-transform: uppercase; }
  .rating-slider { flex: 1; accent-color: var(--accent2); cursor: pointer; }
  .rating-val { font-family: var(--font-mono); font-size: 13px; font-weight: 700; color: var(--accent3); width: 24px; text-align: right; }

  .btn-primary { background: var(--accent2); border: none; color: #fff; font-family: var(--font-head); font-size: 13px; font-weight: 700; letter-spacing: 2px; padding: 10px 30px; cursor: pointer; transition: background 0.2s; }
  .btn-primary:hover { background: var(--accent); }
  .btn-outline { background: transparent; border: 1px solid var(--border2); color: var(--text2); font-family: var(--font-head); font-size: 11px; font-weight: 600; letter-spacing: 1px; padding: 6px 14px; cursor: pointer; transition: all 0.2s; }
  .btn-outline:hover { border-color: var(--accent); color: var(--accent); }
  .btn-danger { background: rgba(255,107,107,0.08); border: 1px solid rgba(255,107,107,0.4); color: var(--red); font-family: var(--font-head); font-size: 11px; letter-spacing: 1px; padding: 6px 14px; cursor: pointer; }
  .success-banner { background: rgba(74,222,128,0.08); border: 1px solid rgba(74,222,128,0.4); color: var(--green); font-family: var(--font-mono); font-size: 11px; padding: 8px 14px; margin-bottom: 14px; letter-spacing: 1px; }

  /* TBA CONFIG — now 2 rows */
  .tba-config { background: var(--bg3); border: 1px solid var(--border); border-left: 3px solid var(--gold); padding: 16px; margin-bottom: 18px; }
  .tba-config-title { font-family: var(--font-head); font-size: 12px; color: var(--gold2); letter-spacing: 2px; text-transform: uppercase; margin-bottom: 12px; }
  .tba-config-grid { display: grid; grid-template-columns: 1fr 1fr; gap: 10px; margin-bottom: 10px; }
  .tba-field-label { font-family: var(--font-mono); font-size: 10px; color: var(--text3); letter-spacing: 1.5px; text-transform: uppercase; margin-bottom: 5px; }
  .tba-input { width: 100%; background: var(--bg4); border: 1px solid var(--border); color: var(--text); font-family: var(--font-mono); font-size: 11px; padding: 7px 11px; outline: none; }
  .tba-input:focus { border-color: var(--gold); }
  .tba-actions { display: flex; gap: 8px; align-items: center; }
  .tba-status { font-family: var(--font-mono); font-size: 10px; color: var(--text3); margin-top: 8px; letter-spacing: 1px; }
  .tba-help { font-size: 11px; color: var(--text3); margin-top: 8px; line-height: 1.7; }
  .tba-help a { color: var(--accent3); }

  .tabs-inline { display: flex; gap: 0; margin-bottom: 16px; border-bottom: 1px solid var(--border2); }
  .tab-inline { font-family: var(--font-head); font-size: 11px; font-weight: 600; letter-spacing: 1.5px; padding: 7px 16px; border: none; background: transparent; color: var(--text3); cursor: pointer; border-bottom: 2px solid transparent; margin-bottom: -1px; }
  .tab-inline.active { color: var(--accent3); border-bottom-color: var(--accent); }

  .table-controls { display: flex; gap: 8px; align-items: center; margin-bottom: 14px; flex-wrap: wrap; }
  .data-table-wrap { overflow-x: auto; }
  .data-table { width: 100%; border-collapse: collapse; font-size: 11px; }
  .data-table th { background: var(--bg3); font-family: var(--font-mono); font-size: 9px; letter-spacing: 1.5px; color: var(--accent3); text-transform: uppercase; padding: 8px 10px; text-align: left; border-bottom: 1px solid var(--border2); white-space: nowrap; cursor: pointer; user-select: none; }
  .data-table th:hover { color: var(--gold2); }
  .data-table td { padding: 7px 10px; border-bottom: 1px solid var(--border); font-family: var(--font-mono); font-size: 11px; color: var(--text2); white-space: nowrap; }
  .data-table tr:hover td { background: rgba(168,124,255,0.04); }
  .badge { font-family: var(--font-mono); font-size: 10px; padding: 2px 8px; letter-spacing: 1px; }
  .badge-purple { background: rgba(168,124,255,0.15); color: var(--accent3); }
  .badge-gold { background: rgba(240,192,64,0.15); color: var(--gold2); }
  .badge-green { background: rgba(74,222,128,0.14); color: var(--green); }
  .badge-red { background: rgba(255,107,107,0.14); color: var(--red); }
  .badge-blue { background: rgba(96,165,250,0.15); color: #93c5fd; }
  .record-count { font-family: var(--font-mono); font-size: 10px; color: var(--text3); letter-spacing: 1px; }
  .empty-state { text-align: center; padding: 36px; color: var(--text3); font-family: var(--font-mono); font-size: 11px; letter-spacing: 1px; }
  .api-banner { background: rgba(240,192,64,0.07); border: 1px solid rgba(240,192,64,0.25); color: var(--gold2); font-family: var(--font-mono); font-size: 10px; padding: 8px 13px; margin-bottom: 14px; letter-spacing: 1px; }

  .strategy-grid { display: grid; grid-template-columns: 1fr 1fr; gap: 14px; }
  .strat-card { background: var(--bg3); border: 1px solid var(--border); border-top: 2px solid var(--accent2); padding: 16px; }
  .strat-card.gold-top { border-top-color: var(--gold); }
  .strat-card.full { grid-column: 1/-1; }
  .strat-card-title { font-family: var(--font-head); font-size: 13px; font-weight: 700; color: var(--accent3); letter-spacing: 1.5px; text-transform: uppercase; margin-bottom: 14px; padding-bottom: 8px; border-bottom: 1px solid var(--border); }
  .stat-row { display: flex; justify-content: space-between; align-items: center; padding: 5px 0; border-bottom: 1px solid var(--border); }
  .stat-row:last-child { border: none; }
  .stat-name { font-size: 12px; color: var(--text2); }
  .stat-val { font-family: var(--font-mono); font-size: 13px; font-weight: 700; color: var(--accent3); }
  .rank-row { display: flex; align-items: center; gap: 10px; padding: 5px 0; border-bottom: 1px solid var(--border); }
  .rank-row:last-child { border: none; }
  .rank-num { font-family: var(--font-mono); font-size: 10px; width: 22px; flex-shrink: 0; }
  .rank-team { font-family: var(--font-mono); font-size: 12px; color: var(--text); flex: 1; }
  .rank-score { font-family: var(--font-mono); font-size: 12px; color: var(--accent3); }
  .rank-entries { font-family: var(--font-mono); font-size: 10px; color: var(--text3); }
  .pred-inputs { display: flex; gap: 10px; margin-bottom: 14px; flex-wrap: wrap; align-items: flex-end; }
  .pred-alliance { display: flex; flex-direction: column; gap: 6px; }
  .pred-alliance-label { font-family: var(--font-head); font-size: 11px; letter-spacing: 2px; text-transform: uppercase; }
  .pred-alliance.red .pred-alliance-label { color: var(--red); }
  .pred-alliance.blue .pred-alliance-label { color: #93c5fd; }
  .pred-teams { display: flex; gap: 6px; }
  .pred-team-input { width: 72px; background: var(--bg4); border: 1px solid var(--border); color: var(--text); font-family: var(--font-mono); font-size: 12px; padding: 6px 8px; outline: none; }
  .pred-team-input:focus { border-color: var(--accent2); }
  .pred-result-box { background: var(--bg4); border: 1px solid var(--border2); padding: 14px; margin-top: 4px; }
  .pred-teams-row { display: flex; gap: 6px; margin-bottom: 10px; flex-wrap: wrap; align-items: center; }
  .team-chip { font-family: var(--font-mono); font-size: 11px; padding: 3px 10px; border: 1px solid; }
  .team-chip.red { border-color: var(--red); color: var(--red); background: rgba(255,107,107,0.08); }
  .team-chip.blue { border-color: #93c5fd; color: #93c5fd; background: rgba(147,197,253,0.08); }
  .pred-bar-wrap { height: 8px; background: var(--bg); margin: 8px 0; border-radius: 2px; overflow: hidden; display: flex; }
  .pred-bar-red { background: var(--red); transition: width 0.5s; }
  .pred-bar-blue { background: #60a5fa; transition: width 0.5s; }
  .pred-pcts { display: flex; justify-content: space-between; font-family: var(--font-mono); font-size: 13px; font-weight: 700; margin-bottom: 6px; }
  .pred-winner { font-family: var(--font-head); font-size: 14px; letter-spacing: 2px; }
  .pred-conf { font-family: var(--font-mono); font-size: 10px; color: var(--text3); margin-top: 4px; letter-spacing: 1px; }
</style>
</head>
<body>

<div class="header">
  <div class="header-brand">
    <span class="brand-badge">3206</span>
    <div class="brand-col">
      <span class="brand-name">
        <svg style="display:inline-block;width:20px;height:14px;vertical-align:middle;margin-right:6px;" viewBox="0 0 22 16" fill="none" xmlns="http://www.w3.org/2000/svg" aria-hidden="true">
          <path d="M1 14h20M1 14L4 4l5 5 2-7 2 7 5-5 3 10" stroke="#f0c040" stroke-width="1.5" stroke-linejoin="round" stroke-linecap="round"/>
          <circle cx="2.5" cy="3.5" r="1.5" fill="#f0c040"/>
          <circle cx="11" cy="1.5" r="1.5" fill="#f0c040"/>
          <circle cx="19.5" cy="3.5" r="1.5" fill="#f0c040"/>
        </svg>
        Royal T-Wrecks
      </span>
      <span class="brand-sub">FRC Scouting System · Team 3206</span>
    </div>
  </div>
  <div class="nav-tabs">
    <button class="nav-tab active" onclick="showPage('scout',this)">Scout</button>
    <button class="nav-tab admin-locked" onclick="showPage('database',this)">Database</button>
    <button class="nav-tab admin-locked" onclick="showPage('strategy',this)">Strategy</button>
  </div>
  <div class="header-right">
    <span class="admin-status locked" id="admin-status-badge">SCOUTER</span>
    <button class="btn-sm" onclick="openAdminModal()" id="admin-btn">Admin Login</button>
  </div>
</div>

<!-- ADMIN MODAL -->
<div class="modal-overlay" id="admin-modal">
  <div class="modal-box">
    <div class="modal-title">Royal Access</div>
    <div class="modal-sub">ENTER ADMIN PIN</div>
    <input class="lock-input" type="password" id="modal-pin" placeholder="••••••" maxlength="10" onkeydown="if(event.key==='Enter')tryAdmin()">
    <div class="lock-err" id="modal-err"></div>
    <div class="modal-btns">
      <button class="btn-gold" onclick="tryAdmin()">Unlock</button>
      <button class="btn-ghost" onclick="closeAdminModal()">Cancel</button>
    </div>
  </div>
</div>

<!-- PAGE 1: SCOUTING -->
<div class="page active" id="page-scout">
  <div class="section-head">
    <div class="section-head-bar"></div>
    <div>
      <div class="section-title">Match Scouting</div>
      <div class="section-sub">// Subjective data entry — all scouts</div>
    </div>
  </div>

  <div id="scout-success" class="success-banner" style="display:none;">✓ Entry recorded — data saved to database</div>

  <!-- Active event key display for scouts -->
  <div class="event-key-badge" id="scout-event-banner">
    <span class="event-key-label">Active Event:</span>
    <span id="scout-event-display" class="event-key-none">Not set — admin must configure in Database page</span>
  </div>

  <div class="form-grid">
    <div class="form-group">
      <label class="form-label">Match Number</label>
      <input class="form-input" id="f-match" type="number" placeholder="1" min="1">
    </div>
    <div class="form-group">
      <label class="form-label">Team Number</label>
      <input class="form-input" id="f-team" type="number" placeholder="3206">
    </div>
    <div class="form-group">
      <label class="form-label">Scout Name</label>
      <input class="form-input" id="f-scout" placeholder="Your name">
    </div>
    <div class="form-group">
      <label class="form-label">Alliance</label>
      <select class="form-select" id="f-alliance">
        <option value="Red">Red Alliance</option>
        <option value="Blue">Blue Alliance</option>
      </select>
    </div>
    <div class="form-group">
      <label class="form-label">Starting Position</label>
      <select class="form-select" id="f-startpos">
        <option>Center</option>
        <option>Left</option>
        <option>Right</option>
        <option>Unknown</option>
      </select>
    </div>
    <div class="form-group">
      <label class="form-label">Auto Strategy</label>
      <select class="form-select" id="f-auto">
        <option>Full auto routine</option>
        <option>Partial auto</option>
        <option>Mobility only</option>
        <option>Stayed in place</option>
        <option>No auto</option>
      </select>
    </div>
    <div class="form-group">
      <label class="form-label">Endgame Action</label>
      <select class="form-select" id="f-endgame">
        <option>Climbed (High)</option>
        <option>Climbed (Low)</option>
        <option>Parked</option>
        <option>Attempted climb</option>
        <option>No endgame</option>
      </select>
    </div>
    <div class="form-group">
      <label class="form-label">Fouls Committed</label>
      <input class="form-input" id="f-fouls" type="number" min="0" value="0">
    </div>
    <div class="form-group">
      <label class="form-label">Defense Played</label>
      <select class="form-select" id="f-defense">
        <option value="None">None</option>
        <option value="Light">Light</option>
        <option value="Heavy">Heavy</option>
      </select>
    </div>
    <div class="form-group full">
      <label class="form-label">Observations / Notes</label>
      <textarea class="form-textarea" id="f-notes" placeholder="Robot behavior, issues, highlights, anything notable..."></textarea>
    </div>
  </div>

  <div class="ratings-block">
    <div class="ratings-title">Performance Ratings (1 – 10)</div>
    <div id="ratings-container"></div>
  </div>

  <button class="btn-primary" onclick="submitScout()">Submit Scouting Entry</button>
</div>

<!-- PAGE 2: DATABASE -->
<div class="page" id="page-database">
  <div class="section-head">
    <div class="section-head-bar" style="background:var(--gold)"></div>
    <div>
      <div class="section-title" style="color:var(--gold2)">Data Database</div>
      <div class="section-sub">// Objective + subjective data — admin only</div>
    </div>
  </div>

  <div class="tba-config">
    <div class="tba-config-title">The Blue Alliance API Configuration</div>
    <div class="tba-config-grid">
      <div>
        <div class="tba-field-label">Read API Key</div>
        <input class="tba-input" id="tba-key-input" type="text" placeholder="Paste your TBA Read API Key...">
      </div>
      <div>
        <div class="tba-field-label">Event Key</div>
        <input class="tba-input" id="tba-event-input" type="text" placeholder="e.g. 2025mnmi" oninput="updateScoutEventBanner()">
      </div>
    </div>
    <div class="tba-actions">
      <button class="btn-outline" onclick="saveTBAConfig()">Save Config</button>
      <button class="btn-outline" onclick="fetchTBAData()">Fetch TBA Data</button>
    </div>
    <div class="tba-status" id="tba-status">No API key configured</div>
    <div class="tba-help">
      Free key at: <a href="https://www.thebluealliance.com/account" target="_blank">thebluealliance.com/account</a> → "Read API Keys". The event key (e.g. <strong style="color:var(--text2)">2025mnmi</strong>) is set here once by admin — scouts don't need to enter it.
    </div>
  </div>

  <div class="tabs-inline">
    <button class="tab-inline active" onclick="switchDbTab('scouted',this)">Scouted Teams</button>
    <button class="tab-inline" onclick="switchDbTab('tba',this)">TBA Objective Data</button>
  </div>

  <div id="db-scouted">
    <div class="table-controls">
      <input class="form-input" style="width:150px;padding:6px 10px;font-size:12px;" placeholder="Filter team / scout..." id="db-filter" oninput="renderScoutTable()">
      <button class="btn-outline" onclick="exportCSV()">Export CSV</button>
      <button class="btn-danger" onclick="clearAllData()">Clear All</button>
      <span class="record-count" id="record-count"></span>
    </div>
    <div class="data-table-wrap">
      <table class="data-table" id="scout-table">
        <thead><tr>
          <th onclick="sortTable('event')">Event</th>
          <th onclick="sortTable('match')">Match</th>
          <th onclick="sortTable('team')">Team</th>
          <th onclick="sortTable('alliance')">Alliance</th>
          <th onclick="sortTable('driverSkill')">Driver</th>
          <th onclick="sortTable('accuracy')">Accuracy</th>
          <th onclick="sortTable('speed')">Speed</th>
          <th onclick="sortTable('defense')">Defense</th>
          <th onclick="sortTable('consistency')">Consist.</th>
          <th onclick="sortTable('autoScore')">Auto</th>
          <th onclick="sortTable('adaptability')">Adapt.</th>
          <th onclick="sortTable('coopPlay')">Co-op</th>
          <th onclick="sortTable('avgRating')">Avg</th>
          <th onclick="sortTable('endgame')">Endgame</th>
          <th onclick="sortTable('fouls')">Fouls</th>
          <th>Scout</th>
          <th>Notes</th>
          <th></th>
        </tr></thead>
        <tbody id="scout-tbody"></tbody>
      </table>
    </div>
    <div class="empty-state" id="db-empty" style="display:none;">No scouting data yet — submit entries from Page 1</div>
  </div>

  <div id="db-tba" style="display:none;">
    <div class="api-banner">Data from The Blue Alliance. Rankings and OPR are event-specific. Set your event key above and click "Fetch TBA Data".</div>
    <div class="data-table-wrap">
      <table class="data-table">
        <thead><tr>
          <th>Team</th><th>Rank</th><th>OPR</th><th>DPR</th><th>CCWM</th><th>W-L-T</th><th>Avg Score</th>
        </tr></thead>
        <tbody id="tba-tbody">
          <tr><td colspan="7" style="text-align:center;color:var(--text3);padding:24px;font-family:var(--font-mono);font-size:11px;">No TBA data loaded</td></tr>
        </tbody>
      </table>
    </div>
  </div>
</div>

<!-- PAGE 3: STRATEGY -->
<div class="page" id="page-strategy">
  <div class="section-head">
    <div class="section-head-bar" style="background:var(--accent2)"></div>
    <div>
      <div class="section-title" style="color:var(--accent3)">Strategy Center</div>
      <div class="section-sub">// Match predictions &amp; alliance analysis — admin only</div>
    </div>
  </div>
  <div class="strategy-grid">
    <div class="strat-card">
      <div class="strat-card-title">Top Teams by Avg Rating</div>
      <div id="strat-top-teams"><div class="empty-state" style="padding:16px;">No data yet</div></div>
    </div>
    <div class="strat-card gold-top">
      <div class="strat-card-title" style="color:var(--gold2);">Field Summary</div>
      <div id="strat-summary"><div class="empty-state" style="padding:16px;">No data yet</div></div>
    </div>
    <div class="strat-card full">
      <div class="strat-card-title">Match Predictor</div>
      <div class="pred-inputs">
        <div class="pred-alliance red">
          <span class="pred-alliance-label">Red Alliance</span>
          <div class="pred-teams">
            <input class="pred-team-input" id="pred-r1" placeholder="Team 1">
            <input class="pred-team-input" id="pred-r2" placeholder="Team 2">
            <input class="pred-team-input" id="pred-r3" placeholder="Team 3">
          </div>
        </div>
        <div style="font-family:var(--font-head);font-size:14px;color:var(--text3);padding-bottom:6px;">vs</div>
        <div class="pred-alliance blue">
          <span class="pred-alliance-label">Blue Alliance</span>
          <div class="pred-teams">
            <input class="pred-team-input" id="pred-b1" placeholder="Team 1">
            <input class="pred-team-input" id="pred-b2" placeholder="Team 2">
            <input class="pred-team-input" id="pred-b3" placeholder="Team 3">
          </div>
        </div>
        <button class="btn-primary" style="padding:8px 22px;align-self:flex-end;" onclick="runPrediction()">Predict</button>
      </div>
      <div id="pred-result" style="display:none;"></div>
    </div>
    <div class="strat-card full">
      <div class="strat-card-title">Alliance Pick List</div>
      <p style="font-size:11px;color:var(--text3);font-family:var(--font-mono);margin-bottom:12px;letter-spacing:1px;">Teams ranked by composite scouted score — higher = stronger pick candidate</p>
      <div id="strat-picklist"><div class="empty-state" style="padding:16px;">Scout more teams first</div></div>
    </div>
  </div>
</div>

<script>
const ADMIN_PIN = "3206";
let adminUnlocked = false;
let scoutData = [];
let tbaData = {};
let sortKey = 'match';
let sortAsc = true;
let currentPage = 'scout';
let tbaKey = '';
let eventKey = '';
let pendingPage = null;
let pendingBtn = null;

const RATINGS = [
  { id: 'driverSkill', label: 'Driver Skill' },
  { id: 'accuracy', label: 'Scoring Accuracy' },
  { id: 'speed', label: 'Robot Speed' },
  { id: 'defense', label: 'Defense Quality' },
  { id: 'consistency', label: 'Consistency' },
  { id: 'autoScore', label: 'Auto Performance' },
  { id: 'adaptability', label: 'Adaptability' },
  { id: 'coopPlay', label: 'Co-op / Teamwork' },
];

function init() {
  try { const s = localStorage.getItem('twrecks3206_scout'); if (s) scoutData = JSON.parse(s); } catch(e) {}
  try { const t = localStorage.getItem('twrecks3206_tba'); if (t) tbaData = JSON.parse(t); } catch(e) {}
  try {
    const k = localStorage.getItem('twrecks3206_tbakey');
    if (k) { tbaKey = k; document.getElementById('tba-key-input').value = tbaKey; }
  } catch(e) {}
  try {
    const ev = localStorage.getItem('twrecks3206_eventkey');
    if (ev) { eventKey = ev; document.getElementById('tba-event-input').value = eventKey; }
  } catch(e) {}
  updateScoutEventBanner();
  buildRatings();
  if (Object.keys(tbaData).length) document.getElementById('tba-status').textContent = '✓ TBA data loaded from storage';
  else if (tbaKey) document.getElementById('tba-status').textContent = '✓ API key loaded — click Fetch TBA Data';
}

function updateScoutEventBanner() {
  const val = document.getElementById('tba-event-input') ? document.getElementById('tba-event-input').value.trim() : eventKey;
  const display = document.getElementById('scout-event-display');
  if (!display) return;
  if (val) {
    display.className = 'event-key-val';
    display.textContent = val.toUpperCase();
  } else {
    display.className = 'event-key-none';
    display.textContent = 'Not set — admin must configure in Database page';
  }
}

function buildRatings() {
  const c = document.getElementById('ratings-container');
  c.innerHTML = RATINGS.map(r => `
    <div class="rating-row">
      <span class="rating-label">${r.label}</span>
      <input class="rating-slider" type="range" min="1" max="10" value="5" id="r-${r.id}" oninput="document.getElementById('rv-${r.id}').textContent=this.value">
      <span class="rating-val" id="rv-${r.id}">5</span>
    </div>`).join('');
}

function showPage(page, btn) {
  if ((page === 'database' || page === 'strategy') && !adminUnlocked) {
    pendingPage = page; pendingBtn = btn;
    document.getElementById('modal-pin').value = '';
    document.getElementById('modal-err').textContent = '';
    document.getElementById('admin-modal').style.display = 'flex';
    setTimeout(() => document.getElementById('modal-pin').focus(), 50);
    return;
  }
  _activatePage(page, btn);
}

function _activatePage(page, btn) {
  document.querySelectorAll('.page').forEach(p => p.classList.remove('active'));
  document.querySelectorAll('.nav-tab').forEach(t => t.classList.remove('active'));
  document.getElementById('page-' + page).classList.add('active');
  btn.classList.add('active');
  currentPage = page;
  if (page === 'database') { renderScoutTable(); renderTBATable(); }
  if (page === 'strategy') renderStrategy();
}

function openAdminModal() {
  document.getElementById('modal-pin').value = '';
  document.getElementById('modal-err').textContent = '';
  document.getElementById('admin-modal').style.display = 'flex';
  setTimeout(() => document.getElementById('modal-pin').focus(), 50);
}
function closeAdminModal() {
  document.getElementById('admin-modal').style.display = 'none';
  pendingPage = null; pendingBtn = null;
}
function tryAdmin() {
  const pin = document.getElementById('modal-pin').value;
  if (pin === ADMIN_PIN) {
    adminUnlocked = true;
    document.getElementById('admin-modal').style.display = 'none';
    document.getElementById('admin-status-badge').textContent = 'ADMIN';
    document.getElementById('admin-status-badge').className = 'admin-status unlocked';
    document.getElementById('admin-btn').textContent = 'Lock';
    document.getElementById('admin-btn').onclick = lockAdmin;
    document.querySelectorAll('.admin-locked').forEach(t => t.classList.replace('admin-locked','admin-unlocked'));
    if (pendingPage && pendingBtn) { _activatePage(pendingPage, pendingBtn); pendingPage = null; pendingBtn = null; }
  } else {
    document.getElementById('modal-err').textContent = 'Incorrect PIN';
    document.getElementById('modal-pin').value = '';
    document.getElementById('modal-pin').focus();
  }
}
function lockAdmin() {
  adminUnlocked = false;
  document.getElementById('admin-status-badge').textContent = 'SCOUTER';
  document.getElementById('admin-status-badge').className = 'admin-status locked';
  document.getElementById('admin-btn').textContent = 'Admin Login';
  document.getElementById('admin-btn').onclick = openAdminModal;
  document.querySelectorAll('.admin-unlocked').forEach(t => t.classList.replace('admin-unlocked','admin-locked'));
  if (currentPage !== 'scout') document.querySelectorAll('.nav-tab')[0].click();
}

function saveTBAConfig() {
  tbaKey = document.getElementById('tba-key-input').value.trim();
  eventKey = document.getElementById('tba-event-input').value.trim();
  if (!tbaKey) { alert('Please enter an API key.'); return; }
  localStorage.setItem('twrecks3206_tbakey', tbaKey);
  localStorage.setItem('twrecks3206_eventkey', eventKey);
  document.getElementById('tba-status').textContent = '✓ Config saved' + (eventKey ? ' — Event: ' + eventKey.toUpperCase() : '');
  updateScoutEventBanner();
}

async function fetchTBAData() {
  if (!tbaKey) { alert('Save a TBA API key first.'); return; }
  const ev = document.getElementById('tba-event-input').value.trim() || eventKey;
  if (!ev) { alert('Enter an event key (e.g. 2025mnmi) in the Event Key field.'); return; }
  const st = document.getElementById('tba-status');
  st.textContent = 'Fetching ' + ev + '...';
  try {
    const h = { 'X-TBA-Auth-Key': tbaKey };
    const [rr, or] = await Promise.all([
      fetch(`https://www.thebluealliance.com/api/v3/event/${ev}/rankings`, { headers: h }),
      fetch(`https://www.thebluealliance.com/api/v3/event/${ev}/oprs`, { headers: h })
    ]);
    const rj = await rr.json();
    const oj = await or.json();
    const nd = {};
    if (rj.rankings) rj.rankings.forEach(r => {
      const tn = r.team_key.replace('frc','');
      nd[tn] = nd[tn]||{};
      nd[tn].rank = r.rank;
      nd[tn].wins = r.record?.wins||0;
      nd[tn].losses = r.record?.losses||0;
      nd[tn].ties = r.record?.ties||0;
      nd[tn].avgScore = r.sort_orders?.[0];
    });
    if (oj.oprs) Object.entries(oj.oprs).forEach(([k,v])=>{const tn=k.replace('frc','');nd[tn]=nd[tn]||{};nd[tn].opr=v;});
    if (oj.dprs) Object.entries(oj.dprs).forEach(([k,v])=>{const tn=k.replace('frc','');if(nd[tn])nd[tn].dpr=v;});
    if (oj.ccwms) Object.entries(oj.ccwms).forEach(([k,v])=>{const tn=k.replace('frc','');if(nd[tn])nd[tn].ccwm=v;});
    tbaData = nd;
    localStorage.setItem('twrecks3206_tba', JSON.stringify(tbaData));
    st.textContent = '✓ Loaded ' + Object.keys(nd).length + ' teams from ' + ev.toUpperCase();
    renderTBATable();
  } catch(e) { st.textContent = 'Error: ' + e.message; }
}

function submitScout() {
  const team = document.getElementById('f-team').value.trim();
  const match = document.getElementById('f-match').value.trim();
  const scout = document.getElementById('f-scout').value.trim();
  if (!team || !match || !scout) { alert('Please fill in Team Number, Match Number, and Scout Name.'); return; }
  let sum = 0;
  const ratings = {};
  RATINGS.forEach(r => { const v = parseInt(document.getElementById('r-'+r.id).value); ratings[r.id]=v; sum+=v; });
  const entry = {
    id: Date.now(),
    event: eventKey || 'N/A',
    match: parseInt(match),
    team: parseInt(team),
    alliance: document.getElementById('f-alliance').value,
    startPos: document.getElementById('f-startpos').value,
    auto: document.getElementById('f-auto').value,
    endgame: document.getElementById('f-endgame').value,
    fouls: parseInt(document.getElementById('f-fouls').value)||0,
    defenseType: document.getElementById('f-defense').value,
    notes: document.getElementById('f-notes').value.trim(),
    scout: scout,
    timestamp: new Date().toISOString(),
    avgRating: parseFloat((sum/RATINGS.length).toFixed(1)),
    ...ratings
  };
  scoutData.push(entry);
  localStorage.setItem('twrecks3206_scout', JSON.stringify(scoutData));
  const s = document.getElementById('scout-success');
  s.style.display = 'block';
  setTimeout(() => s.style.display = 'none', 3000);
  document.getElementById('f-match').value = '';
  document.getElementById('f-team').value = '';
  document.getElementById('f-notes').value = '';
  document.getElementById('f-fouls').value = '0';
  RATINGS.forEach(r => { document.getElementById('r-'+r.id).value=5; document.getElementById('rv-'+r.id).textContent='5'; });
}

function renderScoutTable() {
  const filter = (document.getElementById('db-filter').value||'').toLowerCase();
  let data = scoutData.filter(e => !filter || String(e.team).includes(filter) || e.scout.toLowerCase().includes(filter) || (e.event||'').toLowerCase().includes(filter));
  data.sort((a,b) => {
    let va=a[sortKey], vb=b[sortKey];
    if (typeof va==='string') va=va.toLowerCase();
    if (typeof vb==='string') vb=vb.toLowerCase();
    return sortAsc ? (va>vb?1:-1) : (va<vb?1:-1);
  });
  document.getElementById('record-count').textContent = data.length + ' record' + (data.length!==1?'s':'');
  document.getElementById('db-empty').style.display = data.length===0?'block':'none';
  document.getElementById('scout-table').style.display = data.length===0?'none':'';
  document.getElementById('scout-tbody').innerHTML = data.map(e=>`<tr>
    <td>${e.event}</td><td>${e.match}</td>
    <td><span class="badge badge-purple">${e.team}</span></td>
    <td><span class="badge ${e.alliance==='Red'?'badge-red':'badge-blue'}">${e.alliance}</span></td>
    <td>${e.driverSkill}</td><td>${e.accuracy}</td><td>${e.speed}</td><td>${e.defense}</td>
    <td>${e.consistency}</td><td>${e.autoScore}</td><td>${e.adaptability}</td><td>${e.coopPlay}</td>
    <td><span class="badge ${e.avgRating>=7?'badge-green':e.avgRating>=5?'badge-purple':'badge-red'}">${e.avgRating}</span></td>
    <td style="font-size:10px;max-width:90px;overflow:hidden;text-overflow:ellipsis;">${e.endgame}</td>
    <td>${e.fouls}</td>
    <td style="color:var(--text3);font-size:10px;">${e.scout}</td>
    <td style="max-width:110px;overflow:hidden;text-overflow:ellipsis;font-size:10px;color:var(--text3);" title="${e.notes||''}">${e.notes||'—'}</td>
    <td><button style="background:transparent;border:1px solid rgba(255,107,107,0.3);color:var(--red);font-family:var(--font-mono);font-size:10px;padding:2px 7px;cursor:pointer;" onclick="deleteEntry(${e.id})">×</button></td>
  </tr>`).join('');
}

function renderTBATable() {
  const teams = Object.keys(tbaData);
  if (!teams.length) return;
  document.getElementById('tba-tbody').innerHTML = teams.sort((a,b)=>(tbaData[a].rank||999)-(tbaData[b].rank||999)).map(t=>{
    const d=tbaData[t];
    return `<tr>
      <td><span class="badge badge-gold">${t}</span></td>
      <td>${d.rank||'—'}</td>
      <td>${d.opr!=null?d.opr.toFixed(1):'—'}</td>
      <td>${d.dpr!=null?d.dpr.toFixed(1):'—'}</td>
      <td>${d.ccwm!=null?d.ccwm.toFixed(1):'—'}</td>
      <td>${d.wins!=null?d.wins+'-'+d.losses+'-'+d.ties:'—'}</td>
      <td>${d.avgScore!=null?d.avgScore.toFixed(1):'—'}</td>
    </tr>`;
  }).join('');
}

function sortTable(key) { sortKey===key?(sortAsc=!sortAsc):(sortKey=key,sortAsc=true); renderScoutTable(); }

function deleteEntry(id) {
  if (!confirm('Delete this entry?')) return;
  scoutData = scoutData.filter(e=>e.id!==id);
  localStorage.setItem('twrecks3206_scout', JSON.stringify(scoutData));
  renderScoutTable();
}
function clearAllData() {
  if (!confirm('Clear ALL scouting data? This cannot be undone.')) return;
  scoutData = [];
  localStorage.setItem('twrecks3206_scout', JSON.stringify(scoutData));
  renderScoutTable();
}

function switchDbTab(tab, btn) {
  document.querySelectorAll('.tab-inline').forEach(t=>t.classList.remove('active'));
  btn.classList.add('active');
  document.getElementById('db-scouted').style.display = tab==='scouted'?'block':'none';
  document.getElementById('db-tba').style.display = tab==='tba'?'block':'none';
}

function exportCSV() {
  if (!scoutData.length) { alert('No data to export.'); return; }
  const headers = ['Event','Match','Team','Alliance','StartPos','DriverSkill','Accuracy','Speed','Defense','Consistency','AutoPerf','Adaptability','CoopPlay','AvgRating','AutoStrategy','Endgame','Fouls','DefenseType','Scout','Notes','Timestamp'];
  const rows = scoutData.map(e=>[
    e.event,e.match,e.team,e.alliance,e.startPos,
    e.driverSkill,e.accuracy,e.speed,e.defense,e.consistency,
    e.autoScore,e.adaptability,e.coopPlay,e.avgRating,
    '"'+e.auto+'"','"'+e.endgame+'"',e.fouls,e.defenseType,
    '"'+e.scout+'"','"'+(e.notes||'').replace(/"/g,"'")+'"',e.timestamp
  ]);
  const csv = [headers.join(','),...rows.map(r=>r.join(','))].join('\n');
  const a = document.createElement('a');
  a.href = URL.createObjectURL(new Blob([csv],{type:'text/csv'}));
  a.download = 'royal_twrecks_3206_scouting.csv';
  a.click();
}

function renderStrategy() {
  const teamMap = {};
  scoutData.forEach(e => {
    if (!teamMap[e.team]) teamMap[e.team]={total:0,count:0,ratings:{}};
    teamMap[e.team].total+=e.avgRating; teamMap[e.team].count++;
    RATINGS.forEach(r=>{teamMap[e.team].ratings[r.id]=(teamMap[e.team].ratings[r.id]||0)+e[r.id];});
  });
  const teams = Object.entries(teamMap).map(([t,d])=>({
    team:t, avg:parseFloat((d.total/d.count).toFixed(1)), count:d.count,
    driverSkill:parseFloat((d.ratings.driverSkill/d.count).toFixed(1)),
    accuracy:parseFloat((d.ratings.accuracy/d.count).toFixed(1)),
    autoScore:parseFloat((d.ratings.autoScore/d.count).toFixed(1)),
    speed:parseFloat((d.ratings.speed/d.count).toFixed(1)),
  })).sort((a,b)=>b.avg-a.avg);

  document.getElementById('strat-top-teams').innerHTML = !teams.length
    ? '<div class="empty-state" style="padding:16px;">No data yet</div>'
    : teams.slice(0,8).map((t,i)=>`<div class="rank-row">
        <span class="rank-num" style="color:${i===0?'var(--gold)':i<3?'var(--accent3)':'var(--text3)'}">${i+1}</span>
        <span class="rank-team">Team ${t.team}</span>
        <span class="rank-score">${t.avg}/10</span>
        <span class="rank-entries">(${t.count})</span>
      </div>`).join('');

  if (!scoutData.length) {
    document.getElementById('strat-summary').innerHTML = '<div class="empty-state" style="padding:16px;">No data yet</div>';
  } else {
    const allAvg=(scoutData.reduce((s,e)=>s+e.avgRating,0)/scoutData.length).toFixed(1);
    document.getElementById('strat-summary').innerHTML = `
      <div class="stat-row"><span class="stat-name">Teams Scouted</span><span class="stat-val">${Object.keys(teamMap).length}</span></div>
      <div class="stat-row"><span class="stat-name">Total Entries</span><span class="stat-val">${scoutData.length}</span></div>
      <div class="stat-row"><span class="stat-name">Field Avg Rating</span><span class="stat-val">${allAvg}</span></div>
      <div class="stat-row"><span class="stat-name">Top Team</span><span class="stat-val">${teams[0]?teams[0].team:'—'}</span></div>
      <div class="stat-row"><span class="stat-name">Active Event</span><span class="stat-val" style="font-size:11px;">${eventKey?eventKey.toUpperCase():'—'}</span></div>`;
  }

  document.getElementById('strat-picklist').innerHTML = !teams.length
    ? '<div class="empty-state" style="padding:16px;">Scout more teams first</div>'
    : `<div class="data-table-wrap"><table class="data-table"><thead><tr>
        <th>Rank</th><th>Team</th><th>Composite</th><th>Driver</th><th>Accuracy</th><th>Auto</th><th>Speed</th><th>Matches</th>
      </tr></thead><tbody>${teams.map((t,i)=>`<tr>
        <td><span class="badge ${i<1?'badge-gold':i<3?'badge-purple':'badge-green'}">#${i+1}</span></td>
        <td style="color:var(--text);font-weight:500;">${t.team}</td>
        <td><span class="badge ${t.avg>=7?'badge-green':t.avg>=5?'badge-purple':'badge-red'}">${t.avg}</span></td>
        <td>${t.driverSkill}</td><td>${t.accuracy}</td><td>${t.autoScore}</td><td>${t.speed}</td>
        <td style="color:var(--text3);">${t.count}</td>
      </tr>`).join('')}</tbody></table></div>`;
}

function getTeamAvg(num) {
  const entries = scoutData.filter(e=>String(e.team)===String(num));
  if (entries.length) return entries.reduce((s,e)=>s+e.avgRating,0)/entries.length;
  const td = tbaData[num];
  return td?.opr!=null ? Math.min(10,td.opr/15) : null;
}

function runPrediction() {
  const red=[document.getElementById('pred-r1').value,document.getElementById('pred-r2').value,document.getElementById('pred-r3').value].map(v=>v.trim()).filter(Boolean);
  const blue=[document.getElementById('pred-b1').value,document.getElementById('pred-b2').value,document.getElementById('pred-b3').value].map(v=>v.trim()).filter(Boolean);
  if (!red.length||!blue.length) { alert('Enter at least one team per alliance.'); return; }
  const allScores=[...red,...blue].map(t=>getTeamAvg(t)).filter(v=>v!==null);
  const fallback=allScores.length?allScores.reduce((s,v)=>s+v,0)/allScores.length:5;
  const redAvg=red.map(t=>getTeamAvg(t)??fallback).reduce((s,v)=>s+v,0)/red.length;
  const blueAvg=blue.map(t=>getTeamAvg(t)??fallback).reduce((s,v)=>s+v,0)/blue.length;
  const total=redAvg+blueAvg;
  const redPct=Math.round((redAvg/total)*100);
  const bluePct=100-redPct;
  const favored=redPct>=bluePct?'RED':'BLUE';
  const conf=Math.abs(redPct-bluePct);
  const confLabel=conf<8?'Too close to call':conf<20?'Slight advantage':'Strong favorite';
  const missing=[...red,...blue].filter(t=>getTeamAvg(t)===null);
  const r=document.getElementById('pred-result');
  r.style.display='block';
  r.innerHTML=`<div class="pred-result-box">
    <div class="pred-teams-row">
      ${red.map(t=>`<span class="team-chip red">${t}</span>`).join('')}
      <span style="color:var(--text3);font-family:var(--font-mono);font-size:12px;padding:0 4px;">vs</span>
      ${blue.map(t=>`<span class="team-chip blue">${t}</span>`).join('')}
    </div>
    <div class="pred-pcts"><span style="color:var(--red);">Red ${redPct}%</span><span style="color:#93c5fd;">Blue ${bluePct}%</span></div>
    <div class="pred-bar-wrap"><div class="pred-bar-red" style="width:${redPct}%"></div><div class="pred-bar-blue" style="width:${bluePct}%"></div></div>
    <div class="pred-winner" style="color:${favored==='RED'?'var(--red)':'#93c5fd'}">${favored} — ${confLabel}</div>
    <div class="pred-conf">Avg scores: Red ${redAvg.toFixed(1)} | Blue ${blueAvg.toFixed(1)}${missing.length?' · ⚠ No data for: '+missing.join(', ')+' (field avg used)':' · All teams have scouting data'}</div>
  </div>`;
}

init();
</script>
</body>
</html>
