/**
 * MEDIREFLECT AI · Interactive Mobile Application Logic
 * Synchronized with Figma / Untitled.zip UI Design
 */

// ==========================================
// STATE MANAGEMENT
// ==========================================
let appState = {
  profile: {
    name: "Laurent Indra Febrian",
    nim: "012024001",
    department: "Ilmu Penyakit Dalam",
    hospital: "RSUD Dr. Soetomo",
    supervisor: "dr. Sp.PD, Subsp. (K)",
    geminiKey: ""
  },
  activeTab: "beranda",
  gibbsForm: {
    step: 1, // 1 to 6
    caseName: "Pasien sesak napas akut dengan hipertensi emergensi",
    rotation: "Rotasi Interna — RSUD Dr. Soetomo",
    mood: "Cemas",
    stages: {
      1: "Hari ini saya merawat Tn. X, 58 tahun, datang dengan sesak napas mendadak. Saat visite pagi, tekanan darahnya 180/110 mmHg. Saya sempat panik saat pasien tampak gelisah dan saturasinya turun ke 89%.",
      2: "Saya merasa sangat tegang dan khawatir membuat keputusan yang keliru. Ada perasaan ragu apakah harus langsung memberi antihipertensi parenteral atau menunggu instruksi konsulen.",
      3: "Hal baik: Saya segera memposisikan pasien semi-fowler dan memasang kanul oksigen 4 lpm. Hal kurang baik: Saya terlambat melaporkan perburukan klinis ini ke dokter jaga ruangan karena rasa sungkan.",
      4: "Kepanikan terjadi karena saya belum terlatih dalam algoritma 'crisis resource management' dan komunikasi darurat SBAR dalam situasi kritis akut.",
      5: "Saya menyadari bahwa komunikasi eskalasi segera (calling for help) adalah prioritas keselamatan pasien nomor satu, di atas rasa takut atau sungkan.",
      6: "Saya akan menghafal algoritma hipertensi emergensi dan mempraktikkan simulasi SBAR sebelum giliran dinas jaga berikutnya."
    }
  },
  chatMessages: [],
  currentGibbsStep: 0,
  reflections: [],
  activeReflection: null
};

// ==========================================
// INITIALIZATION
// ==========================================
document.addEventListener("DOMContentLoaded", () => {
  loadSavedData();
  updateTimeDisplay();
  setInterval(updateTimeDisplay, 10000);
  initDefaultReflectionIfEmpty();
  renderDashboard();
  loadGibbsFormStep(1);

  // Render Charts when progress tab is ready
  setTimeout(() => {
    renderCompetencyRadar();
    renderDepthTrendLine();
  }, 300);
});

function updateTimeDisplay() {
  const now = new Date();
  const hours = String(now.getHours()).padStart(2, '0');
  const minutes = String(now.getMinutes()).padStart(2, '0');
  const timeElem = document.getElementById("status-time");
  if (timeElem) timeElem.textContent = `${hours}:${minutes}`;
}

function loadSavedData() {
  const savedProfile = localStorage.getItem("medireflect_profile");
  if (savedProfile) {
    try { appState.profile = JSON.parse(savedProfile); } catch (e) {}
  }

  const savedReflections = localStorage.getItem("medireflect_reflections");
  if (savedReflections) {
    try { appState.reflections = JSON.parse(savedReflections); } catch (e) {}
  }
}

function saveData() {
  localStorage.setItem("medireflect_profile", JSON.stringify(appState.profile));
  localStorage.setItem("medireflect_reflections", JSON.stringify(appState.reflections));
}

function initDefaultReflectionIfEmpty() {
  if (appState.reflections.length === 0) {
    const sample = {
      id: "sample-1",
      createdAt: new Date().toISOString(),
      title: "Kasus Hipertensi Emergensi & Sesak Napas Akut",
      department: appState.profile.department,
      studentName: appState.profile.name,
      studentId: appState.profile.nim,
      hospital: appState.profile.hospital,
      supervisorName: appState.profile.supervisor,
      description: "Saat dinas jaga pagi di bangsal interna RSUD Dr. Soetomo, saya merawat pasien laki-laki 58 tahun dengan sesak napas akut dan tensi 180/110 mmHg. Pasien tampak gelisah dan desaturasi ke 89%. Saya sempat tegang saat harus mengambil keputusan klinis cepat.",
      feelings: "Saya merasa detak jantung saya meningkat dan ada rasa ragu apakah tindakan awal saya sudah sesuai dengan protokol gawat darurat.",
      evaluation: "Hal yang baik: Oksigenasi dan posisi semi-fowler segera diberikan sehingga saturasi kembali ke 94%. Hal yang kurang baik: Saya terlambat melakukan eskalasi SBAR ke DPJP.",
      analysis: "Keterlambatan eskalasi dipengaruhi oleh faktor psikologis (sungkan mengganggu konsulen) serta belum terbiasanya alur komunikasi krisis terstruktur.",
      conclusion: "Patient safety selalu berada di atas rasa sungkan pribadi. Komunikasi dini dan terbuka adalah inti profesionalisme klinis.",
      actionPlan: "Mempelajari algoritma hipertensi emergensi dan mempraktikkan komunikasi SBAR mandiri sebelum jaga berikutnya.",
      smartAction: {
        specific: "Menghafal format SBAR dan mengaplikasikannya pada setiap pergantian shift jaga.",
        measurable: "Mampu menyampaikan laporan kasus gawat darurat secara ringkas dalam < 90 detik.",
        achievable: "Bisa dilatih bersama rekan sesama dokter muda sebelum visite.",
        relevant: "Terkait langsung dengan keselamatan pasien dan kompetensi stase Interna.",
        timeBound: "Diterapkan mulai putaran dinas jaga minggu ini."
      },
      depthLevel: "analytical",
      depthRationale: "Refleksi mencapai level Analytical (Level 2): Mahasiswa mengevaluasi faktor psikologis dan sistem komunikasi yang menghambat tindakan medis.",
      keyTakeaway: "Refleksi bukan tentang menyalahkan diri sendiri, tapi tentang memahami dan tumbuh bersama pengalaman."
    };

    appState.reflections.push(sample);
    saveData();
  }
}

// ==========================================
// 5-TAB BOTTOM NAVIGATION
// ==========================================
function switchBottomTab(tabKey) {
  document.querySelectorAll(".mobile-screen").forEach(el => el.classList.remove("active"));
  document.querySelectorAll(".nav-item").forEach(el => el.classList.remove("active"));

  let targetScreen = document.getElementById(`tab-${tabKey}`);
  let targetNav = document.getElementById(`nav-${tabKey}`);

  if (targetScreen) targetScreen.classList.add("active");
  if (targetNav) targetNav.classList.add("active");

  appState.activeTab = tabKey;

  if (tabKey === 'progress') {
    setTimeout(() => {
      renderCompetencyRadar();
      renderDepthTrendLine();
    }, 150);
  } else if (tabKey === 'chat' && appState.chatMessages.length === 0) {
    initChatThread();
  } else if (tabKey === 'beranda') {
    renderDashboard();
  }
}

function navigateToScreen(screenId) {
  document.querySelectorAll(".mobile-screen").forEach(el => el.classList.remove("active"));
  const target = document.getElementById(`screen-${screenId}`);
  if (target) target.classList.add("active");
}

function switchDeviceView(mode) {
  const frame = document.getElementById("phone-frame");
  const btnMobile = document.getElementById("btn-view-mobile");
  const btnTablet = document.getElementById("btn-view-tablet");

  if (mode === 'tablet') {
    frame.classList.add("tablet-view");
    btnTablet.classList.add("active");
    btnMobile.classList.remove("active");
  } else {
    frame.classList.remove("tablet-view");
    btnMobile.classList.add("active");
    btnTablet.classList.remove("active");
  }

  // Redraw charts
  setTimeout(() => {
    renderCompetencyRadar();
    renderDepthTrendLine();
  }, 350);
}

// ==========================================
// DASHBOARD (BERANDA)
// ==========================================
function renderDashboard() {
  document.getElementById("dash-user-name").textContent = `Selamat Pagi, ${appState.profile.name}`;
  document.getElementById("dash-rotation-text").textContent = `Rotasi ${appState.profile.department} — ${appState.profile.hospital}`;
}

function startReflectionWithCategory(cat) {
  document.getElementById("form-case-name").value = `Refleksi: ${cat}`;
  switchBottomTab("refleksi");
}

// ==========================================
// FORM REFLEKSI GIBBS 6-TAHAP (REFLEKSI.png)
// ==========================================
const gibbsStepMeta = {
  1: { tag: "Deskripsi", sub: "Description", q: "Apa yang terjadi?", guide: "Ceritakan kronologi kejadian faktual: apa yang terjadi, siapa saja yang ada di ruangan, apa tugas Anda, dan bagaimana situasi klinis berkembang." },
  2: { tag: "Perasaan", sub: "Feelings", q: "Apa yang Anda rasakan?", guide: "Jelaskan emosi dan respon internal Anda saat peristiwa terjadi maupun setelahnya. Apakah cemas, gugup, bangga, atau merasa bersalah?" },
  3: { tag: "Evaluasi", sub: "Evaluation", q: "Apa yang baik dan buruk?", guide: "Tinjau secara jujur apa aspek dari tindakan Anda yang sudah berjalan lancar, dan apa yang terasa kurang berhasil atau perlu diperbaiki." },
  4: { tag: "Analisis", sub: "Analysis", q: "Mengapa hal itu terjadi?", guide: "Gali lebih dalam akar penyebabnya. Apakah ada faktor beban kerja, komunikasi tim, pemahaman guideline/SOP, atau keraguan psikomotorik?" },
  5: { tag: "Kesimpulan", sub: "Conclusion", q: "Apa pelajaran bagi diri Anda?", guide: "Apa insight dan pemahaman baru yang Anda peroleh tentang diri Anda sendiri sebagai calon dokter dari pengalaman berharga ini?" },
  6: { tag: "Rencana Aksi", sub: "Action Plan", q: "Apa komitmen tindakan ke depan?", guide: "Rumuskan rencana konkret (SMART: Specific, Measurable, Achievable, Relevant, Time-bound) jika situasi serupa terulang di masa mendatang." }
};

function setGibbsFormStep(stepNum) {
  // Save current step content before switching
  saveCurrentFormStepContent();

  appState.gibbsForm.step = stepNum;
  loadGibbsFormStep(stepNum);
}

function loadGibbsFormStep(stepNum) {
  // Update progress and tabs UI
  document.getElementById("form-step-counter").textContent = `Tahap ${stepNum} / 6`;
  document.getElementById("form-progress-fill").style.width = `${(stepNum / 6) * 100}%`;

  for (let i = 1; i <= 6; i++) {
    const btn = document.getElementById(`tab-step-${i}`);
    if (btn) {
      if (i === stepNum) btn.classList.add("active");
      else btn.classList.remove("active");
    }
  }

  // Update text & guidance
  const meta = gibbsStepMeta[stepNum];
  document.getElementById("stage-tag-title").textContent = meta.tag;
  document.getElementById("stage-tag-sub").textContent = meta.sub;
  document.getElementById("stage-question-text").textContent = meta.q;
  document.getElementById("guide-content-box").textContent = meta.guide;

  // Populate text area
  const currentText = appState.gibbsForm.stages[stepNum] || "";
  const textarea = document.getElementById("form-stage-text");
  textarea.value = currentText;
  updateFormWordCount(currentText);

  // Button text
  const nextBtn = document.getElementById("btn-form-next");
  if (stepNum === 6) {
    nextBtn.innerHTML = `<span>Selesai &amp; Ekspor PDF</span> <i class="fa-solid fa-file-pdf"></i>`;
  } else {
    nextBtn.innerHTML = `<span>Lanjut</span> <i class="fa-solid fa-arrow-right"></i>`;
  }
}

function saveCurrentFormStepContent() {
  const textarea = document.getElementById("form-stage-text");
  if (textarea) {
    appState.gibbsForm.stages[appState.gibbsForm.step] = textarea.value.trim();
  }
}

function nextGibbsFormStep() {
  saveCurrentFormStepContent();

  if (appState.gibbsForm.step < 6) {
    setGibbsFormStep(appState.gibbsForm.step + 1);
  } else {
    // Generate reflection object & open Report Screen
    compileFormToReflection();
  }
}

function compileFormToReflection() {
  saveCurrentFormStepContent();
  const caseName = document.getElementById("form-case-name").value.trim() || "Refleksi Kasus Klinis";
  const stages = appState.gibbsForm.stages;

  const newRef = {
    id: "ref-" + Date.now(),
    createdAt: new Date().toISOString(),
    title: caseName,
    department: appState.profile.department,
    studentName: appState.profile.name,
    studentId: appState.profile.nim,
    hospital: appState.profile.hospital,
    supervisorName: appState.profile.supervisor,
    description: stages[1] || "Deskripsi kejadian klinis.",
    feelings: stages[2] || "Perasaan yang dialami saat tindakan berlangsung.",
    evaluation: stages[3] || "Evaluasi hal positif dan aspek yang perlu perbaikan.",
    analysis: stages[4] || "Analisis faktor penyebab dan tinjauan klinis.",
    conclusion: stages[5] || "Kesimpulan pembelajaran tentang diri dan situasi.",
    actionPlan: stages[6] || "Rencana tindakan dan komitmen perbaikan.",
    smartAction: {
      specific: "Melakukan simulasi mandiri dan membaca SOP sebelum dinas.",
      measurable: "Mampu melakukan prosedur secara mandiri tanpa keraguan pada 2 pasien rotasi.",
      achievable: "Didukung bimbingan supervisor dan residen ruangan.",
      relevant: "Terkait langsung dengan capaian kompetensi stase " + appState.profile.department,
      timeBound: "Tercapai sebelum minggu ketiga stase berakhir."
    },
    depthLevel: "analytical",
    depthRationale: "Refleksi mencapai level Analytical: Mahasiswa menguraikan 6 fase Gibbs secara lengkap dan menyusun rencana tindakan terukur.",
    keyTakeaway: "Refleksi yang jujur mengubah pengalaman klinis biasa menjadi keahlian profesional sejati."
  };

  appState.activeReflection = newRef;
  appState.reflections.unshift(newRef);
  saveData();

  renderReportScreen(newRef);
  navigateToScreen("report");
  showToast("Laporan Refleksi Gibbs berhasil disusun!");
}

function selectMood(el, mood) {
  document.querySelectorAll(".mood-btn").forEach(b => b.classList.remove("selected"));
  el.classList.add("selected");
  appState.gibbsForm.mood = mood;
  showToast(`Mood dipilih: ${mood}`);
}

function toggleGuideAccordion() {
  const box = document.getElementById("guide-content-box");
  const arrow = document.getElementById("guide-arrow");
  if (box.style.display === "none") {
    box.style.display = "block";
    arrow.classList.add("open");
  } else {
    box.style.display = "none";
    arrow.classList.remove("open");
  }
}

function updateFormWordCount(text) {
  const words = text.trim() ? text.trim().split(/\s+/).length : 0;
  const counter = document.getElementById("form-word-count");
  if (counter) counter.textContent = `${words} kata · ${text.length} karakter`;
}

function simulateVoiceNoteForm() {
  const sample = "Saat visite pagi bersama DPJP, saya merasa gugup ketika ditanya mengenai diferensial diagnosis pasien sesak napas. Namun saya berusaha menyampaikan penemuan suara ronkhi halus di basal paru.";
  document.getElementById("form-stage-text").value = sample;
  updateFormWordCount(sample);
  showToast("Transkripsi suara dimasukkan!");
}

function insertTemplateContent() {
  const step = appState.gibbsForm.step;
  const templates = {
    1: "Pada saat dinas di bangsal [Stase], saya mendapati pasien dengan keluhan [Gejala Utama]. Situasi klinis yang berkembang yaitu...",
    2: "Saat kejadian tersebut berlangsung, respon emosional pertama saya adalah [Cemas / Ragu / Tertekan] karena...",
    3: "Hal yang berjalan positif pada tindakan ini adalah [Sikap ramah / Persiapan alat], sedangkan hal yang kurang optimal adalah...",
    4: "Peristiwa ini kemungkinan terjadi karena kurangnya latihan mandiri serta beban kerja yang tinggi di bangsal saat itu...",
    5: "Dari insiden ini, saya menyimpulkan bahwa komunikasi yang jelas dan ketenangan sangat penting dalam keselamatan pasien...",
    6: "Untuk rotasi berikutnya, saya berkomitmen untuk mempersiapkan checklist alat dan melakukan briefing 5 menit sebelum prosedur..."
  };

  document.getElementById("form-stage-text").value = templates[step];
  updateFormWordCount(templates[step]);
  showToast("Template panduan berhasil dimasukkan!");
}

// ==========================================
// CHATBOT CONSULT (AI GUIDE)
// ==========================================
function initChatThread() {
  appState.chatMessages = [];
  appState.currentGibbsStep = 0;

  const welcomeText = `Halo! Saya AI Guide Refleksi Anda.\n\nSaya di sini untuk membantu Anda mengeksplorasi pengalaman klinis lebih dalam — bukan untuk menulis refleksi, tapi untuk membantu Anda menemukan insight sendiri melalui pertanyaan.\n\nCeritakan pengalaman klinis terbaru Anda yang berkesan di stase ${appState.profile.department}. Apa yang terjadi?`;

  appendMessage("ai", welcomeText);
  document.getElementById("quick-scenarios-bar").style.display = "flex";
  document.getElementById("synthesize-cta-wrapper").style.display = "none";
}

function appendMessage(sender, text) {
  appState.chatMessages.push({ sender, text, timestamp: new Date() });
  const container = document.getElementById("chat-messages-container");

  const wrapper = document.createElement("div");
  wrapper.className = `message-bubble-wrapper ${sender}`;

  if (sender === 'ai') {
    wrapper.innerHTML = `
      <div class="message-bubble">
        <div class="ai-sender-tag"><i class="fa-solid fa-sparkles"></i> AI Guide</div>
        <div>${formatText(text)}</div>
      </div>
    `;
  } else {
    wrapper.innerHTML = `
      <div class="message-bubble">
        <div>${formatText(text)}</div>
      </div>
    `;
  }

  container.appendChild(wrapper);
  container.scrollTop = container.scrollHeight;

  const userMsgCount = appState.chatMessages.filter(m => m.sender === 'user').length;
  if (userMsgCount >= 2) {
    document.getElementById("synthesize-cta-wrapper").style.display = "block";
  }
}

function formatText(text) {
  return text.replace(/\n/g, '<br>');
}

function handleInputKey(e) {
  if (e.key === "Enter" && !e.shiftKey) {
    e.preventDefault();
    sendUserMessage();
  }
}

function sendUserMessage() {
  const input = document.getElementById("chat-input-text");
  const text = input.value.trim();
  if (!text) return;

  input.value = "";
  appendMessage("user", text);
  document.getElementById("quick-scenarios-bar").style.display = "none";

  showTyping(true);

  setTimeout(async () => {
    const aiResponse = await generateAiScaffoldingResponse(text);
    showTyping(false);
    appendMessage("ai", aiResponse);
  }, 900);
}

function showTyping(show) {
  const el = document.getElementById("chat-typing-indicator");
  if (el) el.style.display = show ? "flex" : "none";
  const container = document.getElementById("chat-messages-container");
  container.scrollTop = container.scrollHeight;
}

function sendPresetScenario(type) {
  let prompt = "";
  if (type === 'kasus') {
    prompt = "Saya punya kasus gagal pemasangan infus pada pasien lansia dengan vena rapuh saat jaga malam. Saya merasa sangat gugup.";
  } else if (type === 'perasaan') {
    prompt = "Saya merasa sangat cemas dan tidak percaya diri saat menghadapi komplain keluarga pasien tadi pagi.";
  } else if (type === 'pelajaran') {
    prompt = "Apa yang bisa saya pelajari dari kejadian saat konsulen menegur saya karena presentasi kasus yang kurang terstruktur?";
  } else if (type === 'komunikasi') {
    prompt = "Bagaimana cara meningkatkan komunikasi klinis saya kepada pasien yang menolak tindakan pemeriksaan fisik?";
  }

  document.getElementById("chat-input-text").value = prompt;
  sendUserMessage();
}

function simulateVoiceNote() {
  const voiceText = "Voice Note 60 Detik: Saat visite tadi pagi, saya berhasil membangun rapport yang baik dengan pasien stroke yang awalnya enggan bicara. Saya menyadari pentingnya empati.";
  document.getElementById("chat-input-text").value = voiceText;
  sendUserMessage();
}

function resetChat() {
  if (confirm("Reset percakapan untuk kasus baru?")) {
    initChatThread();
  }
}

async function generateAiScaffoldingResponse(userText) {
  const lower = userText.toLowerCase();
  const userCount = appState.chatMessages.filter(m => m.sender === 'user').length;
  const persona = (typeof aiTrainingState !== 'undefined') ? aiTrainingState.persona : { empathy: 4.5, socratic: 4.0, gibbs: 4.2, detectTension: true, autoLiterature: true };

  let prefix = "";
  if (persona.detectTension && userCount === 1) {
    prefix = "💡 *[Zona Refleksi Aman — Percakapan ini murni pembelajaran formatif, bukan bagian dari penilaian ujian stase]*\n\n";
  }

  if (lower.includes("gagal") || lower.includes("gugup") || lower.includes("cemas") || lower.includes("panik") || lower.includes("salah")) {
    if (persona.empathy >= 4.0) {
      return prefix + "Sangat wajar dan manusiawi sekali merasakan cemas atau gentar dalam situasi klinis yang menekan. Pengalaman emosional ini adalah gerbang *transformative learning* sesuai AMEE Guide 44.\n\nMari kita urai bersama secara aman: Saat rasa cemas itu memuncak tadi, apa hal yang paling kamu khawatirkan terjadi?";
    } else {
      return prefix + "Tantangan klinis yang dialami merupakan data penting untuk evaluasi. Mari kita bedah objektif: tindakan prosedural apa yang pertama kali kamu ambil saat itu?";
    }
  }

  if (userCount === 1) {
    return prefix + "Terima kasih sudah berani menceritakan pengalaman ini secara jujur. Saat insiden itu berlangsung di ruangan, apa respon emosional pertamamu dan bagaimana situasinya memengaruhi fokusmu?";
  } else if (userCount === 2) {
    return "Refleksi perasaan yang sangat jujur. Sekarang mari masuk ke tahap Evaluasi Gibbs:\n\nDari seluruh alur kejadian tadi, apa hal yang sebenarnya sudah kamu upayakan dengan baik, dan di bagian mana yang terasa paling di luar kendali?";
  } else if (userCount === 3) {
    if (persona.socratic >= 4.0) {
      return "Analisis yang tajam. Mari kita lakukan Socratic Probing lebih dalam:\n\nAsumsi atau ekspektasi apa yang kamu bawa sebelum tindakan yang ternyata tidak sesuai dengan kondisi riil pasien? Dan bagaimana faktor lingkungan atau hierarki tim berperan di sini?";
    } else {
      return "Evaluasi yang tajam. Mari kita analisa:\n\nMengapa hal itu terjadi? Apakah ada faktor beban kerja, komunikasi tim, atau persiapan keterampilan klinis sebelum tindakan?";
    }
  } else {
    let response = "Refleksi yang sangat matang! Kita sudah sampai di tahap Altered Action.\n\nJika besok kamu menghadapi situasi serupa, langkah konkret dan terukur (SMART) apa yang akan kamu lakukan secara berbeda?";
    if (persona.autoLiterature) {
      response += "\n\n📚 *Rekomendasi EBM/Etika:* Pelajari kembali panduan *Clinical Communication Skills (Sandars, 2009)* & pedoman keselamatan pasien RS.";
    }
    response += "\n\nKetuk tombol **'Sintesis Laporan Gibbs & PDF'** di atas untuk melihat rangkuman resmi portofoliomu!";
    return response;
  }
}

function synthesizeGibbsReport() {
  const userMessages = appState.chatMessages.filter(m => m.sender === 'user').map(m => m.text);
  if (userMessages.length === 0) return;

  const desc = userMessages[0] || "Deskripsi pengalaman klinis.";
  const feel = userMessages[1] || "Merasa tegang dan cemas di hadapan pasien dan tim.";
  const evalText = userMessages[2] || "Mampu menjaga ketenangan dasar, namun komunikasi eskalasi masih perlu ditingkatkan.";
  const analysis = userMessages[3] || "Peristiwa dipicu oleh stres situasional dan perlunya latihan deliberate practice.";
  const conclusion = userMessages[4] || "Menyadari bahwa keselamatan pasien dan ketenangan metakognitif adalah prioritas.";
  const action = userMessages[5] || "Mempersiapkan SOP mandiri dan berani meminta supervisi langsung sebelum tindakan.";

  const newReflection = {
    id: "ref-" + Date.now(),
    createdAt: new Date().toISOString(),
    title: `Refleksi Kasus: ${desc.substring(0, 45)}...`,
    department: appState.profile.department,
    studentName: appState.profile.name,
    studentId: appState.profile.nim,
    hospital: appState.profile.hospital,
    supervisorName: appState.profile.supervisor,
    description: desc,
    feelings: feel,
    evaluation: evalText,
    analysis: analysis,
    conclusion: conclusion,
    actionPlan: action,
    smartAction: {
      specific: "Membaca guideline klinis dan berlatih simulasi mandiri.",
      measurable: "Melakukan prosedur dengan benar pada minimal 2 pasien berikutnya.",
      achievable: "Tersedia bimbingan preseptor di bangsal.",
      relevant: "Terkait langsung kompetensi stase " + appState.profile.department,
      timeBound: "Diterapkan mulai dinas jaga minggu ini."
    },
    depthLevel: "analytical",
    depthRationale: "Refleksi mencapai level Analytical: Mahasiswa mampu menelaah faktor manusia dan menyusun rencana tindakan konkret.",
    keyTakeaway: "Refleksi yang jujur mengubah pengalaman klinis biasa menjadi keahlian profesional sejati."
  };

  appState.activeReflection = newReflection;
  appState.reflections.unshift(newReflection);
  saveData();

  renderReportScreen(newReflection);
  navigateToScreen("report");
  showToast("Laporan Refleksi Gibbs berhasil disintesis!");
}

function openExistingReflection(id) {
  const item = appState.reflections.find(r => r.id === id) || appState.reflections[0];
  if (item) {
    appState.activeReflection = item;
    renderReportScreen(item);
    navigateToScreen("report");
  }
}

function renderReportScreen(ref) {
  document.getElementById("report-dept-badge").textContent = ref.department;
  document.getElementById("rep-stase-tag").textContent = `Stase ${ref.department}`;
  document.getElementById("rep-title").textContent = ref.title;
  document.getElementById("rep-author-info").textContent = `Oleh: ${ref.studentName} (${ref.studentId}) · ${ref.hospital}`;
  document.getElementById("rep-takeaway").textContent = `"${ref.keyTakeaway}"`;

  // Gibbs 6 Stages
  document.getElementById("rep-body-description").textContent = ref.description;
  document.getElementById("rep-body-feelings").textContent = ref.feelings;
  document.getElementById("rep-body-evaluation").textContent = ref.evaluation;
  document.getElementById("rep-body-analysis").textContent = ref.analysis;
  document.getElementById("rep-body-conclusion").textContent = ref.conclusion;
  document.getElementById("rep-body-actionPlan").textContent = ref.actionPlan;

  // SMART table
  document.getElementById("smart-val-specific").textContent = ref.smartAction.specific;
  document.getElementById("smart-val-measurable").textContent = ref.smartAction.measurable;
  document.getElementById("smart-val-achievable").textContent = ref.smartAction.achievable;
  document.getElementById("smart-val-relevant").textContent = ref.smartAction.relevant;
  document.getElementById("smart-val-timebound").textContent = ref.smartAction.timeBound;

  // Sync previews
  document.getElementById("sync-desc").textContent = ref.description;
  document.getElementById("sync-feelings").textContent = ref.feelings;
  document.getElementById("sync-eval").textContent = ref.evaluation;
  document.getElementById("sync-analysis").textContent = ref.analysis;
  document.getElementById("sync-conclusion").textContent = ref.conclusion;
  document.getElementById("sync-action").textContent = ref.actionPlan;
}

// ==========================================
// RADAR & TREND CHARTS (CANVAS IMPLEMENTATION)
// ==========================================
function renderCompetencyRadar() {
  const canvas = document.getElementById("competencyRadarCanvas");
  if (!canvas) return;
  const ctx = canvas.getContext("2d");
  const width = canvas.width;
  const height = canvas.height;
  const centerX = width / 2;
  const centerY = height / 2;
  const radius = Math.min(centerX, centerY) - 36;

  ctx.clearRect(0, 0, width, height);

  const axes = [
    { label: "Clinical Reasoning", value: 0.78 },
    { label: "Komunikasi", value: 0.85 },
    { label: "Profesionalisme", value: 0.92 },
    { label: "Empati", value: 0.70 },
    { label: "Patient Safety", value: 0.80 },
    { label: "Teamwork", value: 0.75 }
  ];

  const totalAxes = axes.length;
  const angleStep = (Math.PI * 2) / totalAxes;

  // Draw background web concentric polygons
  const levels = 4;
  ctx.strokeStyle = "#e2e8f0";
  ctx.lineWidth = 1;

  for (let l = 1; l <= levels; l++) {
    const r = (radius / levels) * l;
    ctx.beginPath();
    for (let i = 0; i < totalAxes; i++) {
      const angle = i * angleStep - Math.PI / 2;
      const x = centerX + r * Math.cos(angle);
      const y = centerY + r * Math.sin(angle);
      if (i === 0) ctx.moveTo(x, y);
      else ctx.lineTo(x, y);
    }
    ctx.closePath();
    ctx.stroke();
  }

  // Draw axis lines & labels
  ctx.font = "10px Plus Jakarta Sans, sans-serif";
  ctx.fillStyle = "#64748b";
  ctx.textAlign = "center";
  ctx.textBaseline = "middle";

  for (let i = 0; i < totalAxes; i++) {
    const angle = i * angleStep - Math.PI / 2;
    const x = centerX + radius * Math.cos(angle);
    const y = centerY + radius * Math.sin(angle);

    ctx.beginPath();
    ctx.moveTo(centerX, centerY);
    ctx.lineTo(x, y);
    ctx.stroke();

    // Text placement
    const textRadius = radius + 18;
    const tx = centerX + textRadius * Math.cos(angle);
    const ty = centerY + textRadius * Math.sin(angle);
    ctx.fillText(axes[i].label, tx, ty);
  }

  // Draw Filled Value Polygon
  ctx.beginPath();
  for (let i = 0; i < totalAxes; i++) {
    const angle = i * angleStep - Math.PI / 2;
    const r = radius * axes[i].value;
    const x = centerX + r * Math.cos(angle);
    const y = centerY + r * Math.sin(angle);
    if (i === 0) ctx.moveTo(x, y);
    else ctx.lineTo(x, y);
  }
  ctx.closePath();

  ctx.fillStyle = "rgba(19, 138, 150, 0.25)";
  ctx.fill();
  ctx.strokeStyle = "#138a96";
  ctx.lineWidth = 2;
  ctx.stroke();

  // Draw Point Dots
  ctx.fillStyle = "#138a96";
  for (let i = 0; i < totalAxes; i++) {
    const angle = i * angleStep - Math.PI / 2;
    const r = radius * axes[i].value;
    const x = centerX + r * Math.cos(angle);
    const y = centerY + r * Math.sin(angle);

    ctx.beginPath();
    ctx.arc(x, y, 3.5, 0, Math.PI * 2);
    ctx.fill();
  }
}

function renderDepthTrendLine() {
  const canvas = document.getElementById("depthTrendCanvas");
  if (!canvas) return;
  const ctx = canvas.getContext("2d");
  const width = canvas.width;
  const height = canvas.height;

  ctx.clearRect(0, 0, width, height);

  const points = [
    { label: "M1", val: 50 },
    { label: "M2", val: 58 },
    { label: "M3", val: 62 },
    { label: "M4", val: 68 },
    { label: "M5", val: 74 },
    { label: "M6", val: 82 }
  ];

  const padLeft = 36;
  const padRight = 20;
  const padBottom = 26;
  const padTop = 16;

  const chartW = width - padLeft - padRight;
  const chartH = height - padTop - padBottom;

  // Draw horizontal grid lines
  ctx.strokeStyle = "#f1f5f9";
  ctx.lineWidth = 1;
  ctx.font = "9px Plus Jakarta Sans, sans-serif";
  ctx.fillStyle = "#94a3b8";
  ctx.textAlign = "right";

  const yLevels = [0, 25, 50, 75, 100];
  yLevels.forEach(lvl => {
    const y = padTop + chartH - (lvl / 100) * chartH;
    ctx.beginPath();
    ctx.moveTo(padLeft, y);
    ctx.lineTo(width - padRight, y);
    ctx.stroke();
    ctx.fillText(lvl, padLeft - 6, y + 3);
  });

  // Plot Line
  ctx.beginPath();
  const coords = [];
  points.forEach((p, idx) => {
    const x = padLeft + (chartW / (points.length - 1)) * idx;
    const y = padTop + chartH - (p.val / 100) * chartH;
    coords.push({ x, y });
    if (idx === 0) ctx.moveTo(x, y);
    else ctx.lineTo(x, y);
  });

  ctx.strokeStyle = "#138a96";
  ctx.lineWidth = 2.5;
  ctx.stroke();

  // Draw Points & Labels
  ctx.textAlign = "center";
  coords.forEach((c, idx) => {
    // Dot
    ctx.beginPath();
    ctx.arc(c.x, c.y, 4, 0, Math.PI * 2);
    ctx.fillStyle = "#ffffff";
    ctx.fill();
    ctx.strokeStyle = "#138a96";
    ctx.lineWidth = 2;
    ctx.stroke();

    // X Label
    ctx.fillStyle = "#64748b";
    ctx.fillText(points[idx].label, c.x, height - 6);
  });
}

// ==========================================
// E-PORTFOLIO SYNC & CLIPBOARD
// ==========================================
function copySingleField(elementId, labelName) {
  const el = document.getElementById(elementId);
  if (!el) return;
  copyToClipboard(el.textContent, `${labelName} berhasil disalin ke clipboard!`);
}

function copyFullEssayToClipboard() {
  if (!appState.activeReflection) return;
  const r = appState.activeReflection;
  const text = `======================================================
MEDIREFLECT AI · LAPORAN REFLEKSI KLINIS (GIBBS)
======================================================
Nama Mahasiswa : ${r.studentName}
NIM            : ${r.studentId}
Stase / Bagian : ${r.department}
RS Pendidikan  : ${r.hospital}
DPJP           : ${r.supervisorName}
Topik          : ${r.title}
Tingkat Refleksi: ${r.depthLevel.toUpperCase()}
------------------------------------------------------

1. DESKRIPSI (DESCRIPTION)
${r.description}

2. PERASAAN (FEELINGS)
${r.feelings}

3. EVALUASI (EVALUATION)
${r.evaluation}

4. ANALISIS (ANALYSIS)
${r.analysis}

5. KESIMPULAN (CONCLUSION)
${r.conclusion}

6. RENCANA TINDAKAN (ACTION PLAN - SMART)
${r.actionPlan}

[SMART Action Plan]
- Specific    : ${r.smartAction.specific}
- Measurable  : ${r.smartAction.measurable}
- Achievable  : ${r.smartAction.achievable}
- Relevant    : ${r.smartAction.relevant}
- Time-bound  : ${r.smartAction.timeBound}

Key Takeaway:
"${r.keyTakeaway}"
======================================================`;

  copyToClipboard(text, "Seluruh Esai Refleksi berhasil disalin! Siap ditempel ke e-Portofolio.");
}

function copyJsonToClipboard() {
  if (!appState.activeReflection) return;
  copyToClipboard(JSON.stringify(appState.activeReflection, null, 2), "Data JSON Portofolio berhasil disalin!");
}

function copyToClipboard(text, successMsg) {
  navigator.clipboard.writeText(text).then(() => {
    showToast(successMsg);
  }).catch(() => {
    showToast("Berhasil disalin!");
  });
}

function showToast(msg) {
  const toast = document.getElementById("toast");
  if (!toast) return;
  toast.textContent = msg;
  toast.classList.add("show");
  setTimeout(() => toast.classList.remove("show"), 2500);
}

// ==========================================
// FORMAL ACADEMIC PDF EXPORT
// ==========================================
function openPdfPreviewModal() {
  const r = appState.activeReflection || appState.reflections[0];
  if (!r) return;

  document.getElementById("pdf-id-name").textContent = r.studentName;
  document.getElementById("pdf-id-nim").textContent = r.studentId;
  document.getElementById("pdf-id-dept").textContent = r.department;
  document.getElementById("pdf-id-hospital").textContent = r.hospital;
  document.getElementById("pdf-id-supervisor").textContent = r.supervisorName;
  document.getElementById("pdf-id-depth").textContent = r.depthLevel.toUpperCase();
  document.getElementById("pdf-case-title").textContent = r.title;

  document.getElementById("pdf-desc-text").textContent = r.description;
  document.getElementById("pdf-feel-text").textContent = r.feelings;
  document.getElementById("pdf-eval-text").textContent = r.evaluation;
  document.getElementById("pdf-analysis-text").textContent = r.analysis;
  document.getElementById("pdf-conclusion-text").textContent = r.conclusion;
  document.getElementById("pdf-action-text").textContent = r.actionPlan;

  document.getElementById("pdf-smart-s").textContent = r.smartAction.specific;
  document.getElementById("pdf-smart-m").textContent = r.smartAction.measurable;
  document.getElementById("pdf-smart-a").textContent = r.smartAction.achievable;
  document.getElementById("pdf-smart-r").textContent = r.smartAction.relevant;
  document.getElementById("pdf-smart-t").textContent = r.smartAction.timeBound;

  document.getElementById("pdf-sig-student").textContent = `(${r.studentName})`;
  document.getElementById("pdf-sig-nim").textContent = `NIM: ${r.studentId}`;
  document.getElementById("pdf-sig-supervisor").textContent = `(${r.supervisorName})`;

  document.getElementById("modal-pdf").style.display = "flex";
}

function closePdfModal() {
  document.getElementById("modal-pdf").style.display = "none";
}

function downloadPdfNow() {
  const element = document.getElementById("pdf-printable-area");
  if (!element || !window.html2pdf) {
    window.print();
    return;
  }

  showToast("Menyiapkan unduhan PDF...");
  const opt = {
    margin: [10, 10, 10, 10],
    filename: `Medireflect_${appState.profile.nim}_${appState.profile.department}.pdf`,
    image: { type: 'jpeg', quality: 0.98 },
    html2canvas: { scale: 2, useCORS: true },
    jsPDF: { unit: 'mm', format: 'a4', orientation: 'portrait' }
  };

  html2pdf().set(opt).from(element).save().then(() => {
    showToast("PDF Laporan berhasil diunduh!");
  }).catch(err => {
    window.print();
  });
}

// ==========================================
// ONBOARDING & PROFILE MODALS
// ==========================================
function openAuthModal(mode) {
  document.getElementById("modal-auth").style.display = "flex";
  showAuthSlide(1);
}

function closeAuthModal() {
  document.getElementById("modal-auth").style.display = "none";
}

function showAuthSlide(idx) {
  document.querySelectorAll(".auth-slide").forEach(s => s.classList.remove("active"));
  const target = document.getElementById(`auth-slide-${idx}`);
  if (target) target.classList.add("active");
}

function openProfileModal() {
  document.getElementById("cfg-student-name").value = appState.profile.name;
  document.getElementById("cfg-student-id").value = appState.profile.nim;
  document.getElementById("cfg-student-department").value = appState.profile.department;
  document.getElementById("cfg-student-hospital").value = appState.profile.hospital;
  document.getElementById("cfg-student-supervisor").value = appState.profile.supervisor;
  document.getElementById("cfg-gemini-key").value = appState.profile.geminiKey || "";

  document.getElementById("modal-profile").style.display = "flex";
}

function closeProfileModal() {
  document.getElementById("modal-profile").style.display = "none";
}

function saveProfileModal() {
  appState.profile.name = document.getElementById("cfg-student-name").value.trim() || "dr. Muda";
  appState.profile.nim = document.getElementById("cfg-student-id").value.trim() || "-";
  appState.profile.department = document.getElementById("cfg-student-department").value;
  appState.profile.hospital = document.getElementById("cfg-student-hospital").value.trim() || "RSUD Dr. Soetomo";
  appState.profile.supervisor = document.getElementById("cfg-student-supervisor").value.trim() || "dr. Sp.PD";
  appState.profile.geminiKey = document.getElementById("cfg-gemini-key").value.trim();

  saveData();
  renderDashboard();
  closeProfileModal();
  showToast("Profil mahasiswa berhasil diperbarui!");
}

function toggleDarkMode(checkbox) {
  if (checkbox.checked) {
    document.documentElement.style.setProperty('--phone-bg', '#0f172a');
    document.documentElement.style.setProperty('--phone-surface', '#1e293b');
    document.documentElement.style.setProperty('--phone-text-main', '#f8fafc');
    document.documentElement.style.setProperty('--phone-border', '#334155');
    showToast("Mode gelap diaktifkan.");
  } else {
    document.documentElement.style.setProperty('--phone-bg', '#f3f8f8');
    document.documentElement.style.setProperty('--phone-surface', '#ffffff');
    document.documentElement.style.setProperty('--phone-text-main', '#0f172a');
    document.documentElement.style.setProperty('--phone-border', '#e2e8f0');
    showToast("Mode terang diaktifkan.");
  }
}

// ===================================================
// STUDIO PELATIHAN & KALIBRASI AI (EDUCATOR STUDIO)
// Berdasarkan AMEE Guide No. 44 & Siklus Gibbs 1988
// ===================================================

const defaultExemplars = [
  {
    id: "ex-01",
    title: "Gagal Kanulasi Vena Pasien Pediatri",
    department: "Ilmu Kesehatan Anak",
    clinicalScenario: "Koas gagal memasang infus pada balita dehidrasi setelah 2 kali tusukan, ibu pasien menangis histeris.",
    studentInput: "Dok, tadi di bangsal anak aku gagal pasang infus balita sampai 2 kali tusuk. Ibunya sampai nangis histeris dan marahin aku. Aku merasa bersalah banget dan merasa ga berbakat jadi dokter.",
    idealMentorResponse: "Perasaan bersalah dan ragu pada diri sendiri itu sangat wajar dialami setiap dokter saat menghadapi situasi pediatri yang tegang. Mari kita tarik napas sejenak. Secara teknis vena balita memang sangat kolaps saat dehidrasi. Apa yang membuatmu merasa itu kegagalan pribadi, bukan tantangan klinis bersama tim? Dan apa yang bisa kita pelajari dari cara mengelola ekspektasi orang tua sebelum tindakan?",
    targetGibbsPhase: "Feelings & Analysis",
    targetDepthLevel: "Analytical",
    tags: ["Pediatri", "Keterampilan Klinis", "Manajemen Emosi", "Komunikasi"]
  },
  {
    id: "ex-02",
    title: "Menyampaikan Berita Buruk (SPIKES Protocol)",
    department: "Ilmu Penyakit Dalam",
    clinicalScenario: "Keluarga pasien ca kolon stadium 4 meminta dokter menyembunyikan diagnosis dari ibunya yang sakit.",
    studentInput: "Tadi DPJP meminta saya mendampingi saat menyampaikan hasil biopsi ca kolon stadium 4. Tapi anak tertua minta ibunya jangan diberi tahu. Saya bingung antara hak otonomi pasien dan permintaan keluarga.",
    idealMentorResponse: "Dilema bioetika antara prinsip autonomy pasien dan beneficence menurut persepsi keluarga adalah salah satu ujian klinis paling kompleks. Saat kamu menyaksikan perdebatan itu tadi, nilai-nilai etis apa yang paling berbenturan di benakmu? Menurutmu bagaimana protokol SPIKES bisa menjembatani kekhawatiran keluarga tanpa melanggar hak informasi pasien?",
    targetGibbsPhase: "Analysis & Evaluation",
    targetDepthLevel: "Transformative",
    tags: ["Bioetika", "Breaking Bad News", "SPIKES", "Autonomy"]
  },
  {
    id: "ex-03",
    title: "Kejadian Nyaris Cedera (Near-Miss) Dosis Obat",
    department: "Farmakologi Klinis & IGD",
    clinicalScenario: "Hampir memberikan paracetamol 1 gram ke remaja berbobot 32 kg sebelum ditegur perawat senior.",
    studentInput: "Tadi di IGD rame banget. Aku hampir aja kasih paracetamol 1 gram ke pasien remaja kurus dengan BB 32 kg. Untung perawat senior mengingatkan dosis maksimal mg/kgBB. Aku gemetaran sampai sekarang.",
    idealMentorResponse: "Sangat bersyukur perawat senior menangkap hal itu tepat waktu—inilah bukti pentingnya kolaborasi interprofesional (IPE). Jangan hukum dirimu berlebihan, tetapi mari ubah rasa gemetar ini menjadi benteng keselamatan pasien. Menurutmu, celah sistem apa saat IGD padat tadi yang memicu kelalaian menghitung dosis? Mekanisme double-check apa yang akan kamu terapkan mulai shift berikutnya?",
    targetGibbsPhase: "Evaluation & Action Plan",
    targetDepthLevel: "Transformative",
    tags: ["Patient Safety", "Near Miss", "Interprofesional", "Dosis"]
  },
  {
    id: "ex-04",
    title: "Konflik Hierarki dengan Residen Senior",
    department: "Ilmu Bedah",
    clinicalScenario: "Koas ditegur keras di depan pasien dan perawat saat ronde bedah karena lembar elektrolit belum dicetak.",
    studentInput: "Tadi pagi pas ronde bedah, residen senior bentak saya di depan pasien dan suster karena hasil elektrolit belum saya print. Saya malu dan sakit hati sekali, sampai ga bisa konsentrasi belajar seharian.",
    idealMentorResponse: "Ditegur di depan publik jelas melukai rasa percaya diri dan martabat belajar kita. Emosi sedih, malu, dan marah yang kamu rasakan sangat bisa dipahami. Sekarang, mari pisahkan dua hal: cara penyampaian senior yang kurang ideal, dan urgensi data pasien yang dibutuhkan. Menurutmu, mengapa hasil elektrolit itu begitu krusial bagi keselamatan pasien bedah tadi? Dan bagaimana caramu menjaga profesionalitas sembari tetap merawat kesehatan mentalmu?",
    targetGibbsPhase: "Feelings & Analysis",
    targetDepthLevel: "Analytical",
    tags: ["Hierarki Klinis", "Kesehatan Mental", "Profesionalisme", "Resiliensi"]
  }
];

let aiTrainingState = {
  persona: {
    empathy: 4.5,
    socratic: 4.0,
    gibbs: 4.2,
    detectTension: true,
    autoLiterature: true
  },
  exemplars: [...defaultExemplars]
};

// Inisialisasi Storage Pelatihan
function loadAiTrainingStorage() {
  try {
    const saved = localStorage.getItem("medireflect_training_config");
    if (saved) {
      const parsed = JSON.parse(saved);
      if (parsed.persona) aiTrainingState.persona = { ...aiTrainingState.persona, ...parsed.persona };
      if (parsed.exemplars && Array.isArray(parsed.exemplars)) aiTrainingState.exemplars = parsed.exemplars;
    }
  } catch (e) {
    console.warn("Storage training error:", e);
  }
}

function saveAiTrainingStorage() {
  try {
    localStorage.setItem("medireflect_training_config", JSON.stringify(aiTrainingState));
  } catch (e) {
    console.warn("Storage save error:", e);
  }
}

function openAiTrainingModal() {
  loadAiTrainingStorage();
  
  // Update inputs
  document.getElementById("cfg-slider-empathy").value = aiTrainingState.persona.empathy;
  document.getElementById("cfg-slider-socratic").value = aiTrainingState.persona.socratic;
  document.getElementById("cfg-slider-gibbs").value = aiTrainingState.persona.gibbs;
  document.getElementById("cfg-check-tension").checked = aiTrainingState.persona.detectTension;
  document.getElementById("cfg-check-literature").checked = aiTrainingState.persona.autoLiterature;

  updateTrainingSlider('empathy', aiTrainingState.persona.empathy);
  updateTrainingSlider('socratic', aiTrainingState.persona.socratic);
  updateTrainingSlider('gibbs', aiTrainingState.persona.gibbs);

  renderTrainingExemplars();
  updateJsonlPreview();

  document.getElementById("modal-ai-training").style.display = "flex";
}

function closeAiTrainingModal() {
  document.getElementById("modal-ai-training").style.display = "none";
}

function switchTrainingTab(tabId) {
  document.querySelectorAll(".studio-tab-btn").forEach(b => b.classList.remove("active"));
  document.querySelectorAll(".studio-pane").forEach(p => p.classList.remove("active"));

  const targetBtn = document.getElementById(`btn-tab-${tabId}`);
  const targetPane = document.getElementById(`pane-${tabId}`);
  if (targetBtn) targetBtn.classList.add("active");
  if (targetPane) targetPane.classList.add("active");

  if (tabId === 'export') {
    updateJsonlPreview();
  }
}

function updateTrainingSlider(type, val) {
  const numVal = parseFloat(val);
  aiTrainingState.persona[type] = numVal;

  if (type === 'empathy') {
    document.getElementById("val-empathy").textContent = numVal.toFixed(1) + " / 5.0";
    const desc = document.getElementById("desc-empathy");
    if (numVal >= 4.5) {
      desc.innerHTML = "✨ <strong>Sangat Hangat &amp; Validatif:</strong> Memprioritaskan penenteraman emosi sebelum masuk ke telaah objektif kasus.";
    } else if (numVal >= 3.5) {
      desc.innerHTML = "⚖️ <strong>Seimbang &amp; Suportif:</strong> Memberikan empati hangat disertai dorongan objektivitas klinis.";
    } else {
      desc.innerHTML = "🔬 <strong>Objektif &amp; Ketat:</strong> Berfokus pada kepatuhan SOP klinis dan data medis eksak.";
    }
  } else if (type === 'socratic') {
    document.getElementById("val-socratic").textContent = numVal.toFixed(1) + " / 5.0";
    const desc = document.getElementById("desc-socratic");
    if (numVal >= 4.0) {
      desc.innerHTML = "💡 <strong>Socratic Probing Mendalam:</strong> Menggali mental model implisit mahasiswa lewat pertanyaan bertingkat (AMEE Guide 44).";
    } else if (numVal >= 3.0) {
      desc.innerHTML = "🎯 <strong>Pertanyaan Terarah:</strong> Mengajukan 1-2 pertanyaan reflektif secara bertahap.";
    } else {
      desc.innerHTML = "🤝 <strong>Suportif Pasif:</strong> Mendengarkan dan memvalidasi tanpa banyak menekan mahasiswa.";
    }
  } else if (type === 'gibbs') {
    document.getElementById("val-gibbs").textContent = numVal.toFixed(1) + " / 5.0";
    const desc = document.getElementById("desc-gibbs");
    if (numVal >= 4.0) {
      desc.innerHTML = "📘 <strong>Sangat Terstruktur:</strong> Memandu teratur dari Deskripsi hingga Rencana Tindakan SMART.";
    } else {
      desc.innerHTML = "💬 <strong>Curhat Fleksibel:</strong> Alur obrolan lebih mengalir bebas tanpa sekat fase yang kaku.";
    }
  }
}

function applyPersonaPreset(preset) {
  if (preset === 'empathy') {
    updateTrainingSlider('empathy', 4.9);
    updateTrainingSlider('socratic', 3.2);
    updateTrainingSlider('gibbs', 3.8);
    document.getElementById("cfg-slider-empathy").value = 4.9;
    document.getElementById("cfg-slider-socratic").value = 3.2;
    document.getElementById("cfg-slider-gibbs").value = 3.8;
    showToast("Preset Paliatif & Empati Tinggi diterapkan!");
  } else if (preset === 'socratic') {
    updateTrainingSlider('empathy', 3.8);
    updateTrainingSlider('socratic', 4.8);
    updateTrainingSlider('gibbs', 4.5);
    document.getElementById("cfg-slider-empathy").value = 3.8;
    document.getElementById("cfg-slider-socratic").value = 4.8;
    document.getElementById("cfg-slider-gibbs").value = 4.5;
    showToast("Preset Bedah & Sokratik Kritis diterapkan!");
  } else {
    updateTrainingSlider('empathy', 4.5);
    updateTrainingSlider('socratic', 4.0);
    updateTrainingSlider('gibbs', 4.2);
    document.getElementById("cfg-slider-empathy").value = 4.5;
    document.getElementById("cfg-slider-socratic").value = 4.0;
    document.getElementById("cfg-slider-gibbs").value = 4.2;
    showToast("Preset Standar AMEE Guide 44 diterapkan!");
  }
}

function saveTrainingCalibration() {
  aiTrainingState.persona.empathy = parseFloat(document.getElementById("cfg-slider-empathy").value);
  aiTrainingState.persona.socratic = parseFloat(document.getElementById("cfg-slider-socratic").value);
  aiTrainingState.persona.gibbs = parseFloat(document.getElementById("cfg-slider-gibbs").value);
  aiTrainingState.persona.detectTension = document.getElementById("cfg-check-tension").checked;
  aiTrainingState.persona.autoLiterature = document.getElementById("cfg-check-literature").checked;

  saveAiTrainingStorage();
  updateJsonlPreview();
  showToast("Kalibrasi persona AI berhasil disimpan ke memori!");
}

// Render Bank Kasus (Few-Shot Exemplars)
function renderTrainingExemplars() {
  const container = document.getElementById("training-exemplars-container");
  if (!container) return;

  const countBadge = document.getElementById("badge-exemplar-count");
  if (countBadge) countBadge.textContent = aiTrainingState.exemplars.length;

  container.innerHTML = aiTrainingState.exemplars.map((ex, idx) => `
    <div class="exemplar-item-card">
      <div class="exemplar-card-top">
        <div>
          <div class="exemplar-card-title">#${idx + 1}. ${ex.title}</div>
          <div class="exemplar-card-sub"><i class="fa-solid fa-stethoscope"></i> ${ex.department} · Target Kedalaman: <strong>${ex.targetDepthLevel}</strong></div>
        </div>
        <button class="icon-tool-btn" onclick="deleteExemplar('${ex.id}')" title="Hapus Kasus" style="color:#ef4444;">
          <i class="fa-regular fa-trash-can"></i>
        </button>
      </div>
      <div style="font-size:11.5px; color:#475569; margin:4px 0;"><strong>Kronologi:</strong> ${ex.clinicalScenario}</div>
      <div class="exemplar-quote-box">
        <strong>Curhat Mahasiswa:</strong> "${ex.studentInput}"
      </div>
      <div class="exemplar-ideal-box">
        <strong>Respons Ideal Mentor (AMEE 44):</strong> "${ex.idealMentorResponse}"
      </div>
      <div class="exemplar-tags-wrap">
        ${ex.tags.map(t => `<span class="exemplar-tag">${t}</span>`).join("")}
        <span class="exemplar-tag" style="background:#ccfbf1; color:#0f766e;"><i class="fa-solid fa-bullseye"></i> ${ex.targetGibbsPhase}</span>
      </div>
    </div>
  `).join("");
}

function openAddExemplarModal() {
  document.getElementById("new-ex-title").value = "";
  document.getElementById("new-ex-dept").value = "Ilmu Penyakit Dalam";
  document.getElementById("new-ex-scenario").value = "";
  document.getElementById("new-ex-student").value = "";
  document.getElementById("new-ex-mentor").value = "";
  document.getElementById("modal-add-exemplar").style.display = "flex";
}

function closeAddExemplarModal() {
  document.getElementById("modal-add-exemplar").style.display = "none";
}

function saveNewExemplar() {
  const title = document.getElementById("new-ex-title").value.trim();
  const dept = document.getElementById("new-ex-dept").value.trim() || "Klinik";
  const scenario = document.getElementById("new-ex-scenario").value.trim();
  const student = document.getElementById("new-ex-student").value.trim();
  const mentor = document.getElementById("new-ex-mentor").value.trim();
  const phase = document.getElementById("new-ex-phase").value;

  if (!title || !student || !mentor) {
    showToast("Harap isi judul, curhat mahasiswa, dan respons ideal mentor.");
    return;
  }

  const newEx = {
    id: "ex-" + Date.now(),
    title: title,
    department: dept,
    clinicalScenario: scenario || "Insiden klinis rotasi.",
    studentInput: student,
    idealMentorResponse: mentor,
    targetGibbsPhase: phase,
    targetDepthLevel: "Analytical",
    tags: ["Klinis", dept]
  };

  aiTrainingState.exemplars.push(newEx);
  saveAiTrainingStorage();
  renderTrainingExemplars();
  updateJsonlPreview();
  closeAddExemplarModal();
  showToast("Kasus teladan baru berhasil ditambahkan ke Bank Pelatihan!");
}

function deleteExemplar(id) {
  aiTrainingState.exemplars = aiTrainingState.exemplars.filter(e => e.id !== id);
  saveAiTrainingStorage();
  renderTrainingExemplars();
  updateJsonlPreview();
  showToast("Kasus teladan dihapus.");
}

// Playground Uji Coba Model
async function runPlaygroundSimulation() {
  const input = document.getElementById("playground-input-text").value.trim();
  const dept = document.getElementById("playground-dept-select").value;
  const btn = document.getElementById("btn-run-playground");
  const resultBox = document.getElementById("playground-result-container");
  const body = document.getElementById("play-response-body");

  if (!input) {
    showToast("Masukkan teks curhat terlebih dahulu.");
    return;
  }

  btn.innerHTML = '<i class="fa-solid fa-spinner fa-spin"></i> Menganalisis Model...';
  btn.disabled = true;

  // Simulasi inferensi AI berbobot persona
  setTimeout(() => {
    btn.innerHTML = '<i class="fa-solid fa-play"></i> Uji Respon Model';
    btn.disabled = false;

    const empathy = aiTrainingState.persona.empathy;
    const socratic = aiTrainingState.persona.socratic;

    let response = "";
    let depth = "Analytical";
    let score = "93%";

    if (input.toLowerCase().includes("tegur") || input.toLowerCase().includes("malu") || input.toLowerCase().includes("salah")) {
      if (empathy >= 4.0) {
        response = `Ditegur oleh senior di depan rekan atau pasien saat rotasi ${dept} jelas memicu rasa malu dan menurunkan rasa percaya diri seketika. Perasaan itu sangat manusiawi dan wajar dirasakan.\n\nMari kita bedah secara aman dan formatif: sekarang emosi malunya sudah kita akui, menurutmu mengapa data elektrolit tersebut begitu krusial bagi keselamatan pasien post-op? Dan bagaimana caramu menjaga fokus belajar di shift berikutnya?`;
      } else {
        response = `Situasi di ${dept} ini memberikan pembelajaran objektif. Prosedur apa yang terlewatkan saat persiapan ronde, dan mekanisme cek apa yang akan Anda terapkan?`;
        depth = "Superficial";
        score = "86%";
      }
    } else {
      response = `Refleksi yang sangat kaya mengenai pengalaman di ${dept}. Anda telah menunjukkan pemahaman awal terhadap dinamika lapangan.\n\nJika dikaitkan dengan keselamatan pasien, strategi komunikasi apa yang paling ingin Anda latih sebelum bertugas kembali besok?`;
      depth = "Transformative";
      score = "96%";
    }

    document.getElementById("play-depth-badge").textContent = depth;
    document.getElementById("play-score-badge").textContent = `${score} Calibrated`;
    body.innerHTML = response.replace(/\n\n/g, "<br><br>");
    resultBox.style.display = "block";
    resultBox.scrollIntoView({ behavior: 'smooth', block: 'nearest' });
  }, 750);
}

// JSONL Dataset Generator & Exporter
function generateJsonlString() {
  const systemPrompt = `Anda adalah REFLECTMED AI, Mentor Klinis Reflektif berstandar AMEE Guide No. 44 (Sandars, 2009). Bimbing mahasiswa kedokteran dengan pendekatan Supportive Challenge dan Siklus Gibbs 1988. Skala Empati: ${aiTrainingState.persona.empathy.toFixed(1)}/5.0, Tantangan Sokratik: ${aiTrainingState.persona.socratic.toFixed(1)}/5.0.`;

  return aiTrainingState.exemplars.map(ex => {
    const item = {
      messages: [
        { role: "system", content: systemPrompt },
        { role: "user", content: `[Stase: ${ex.department} - ${ex.title}]\n${ex.studentInput}` },
        { role: "model", content: ex.idealMentorResponse }
      ]
    };
    return JSON.stringify(item);
  }).join("\n");
}

function updateJsonlPreview() {
  const pre = document.getElementById("jsonl-code-preview");
  const badge = document.getElementById("jsonl-row-count-badge");
  if (!pre) return;

  const jsonl = generateJsonlString();
  pre.textContent = jsonl;
  if (badge) badge.textContent = `${aiTrainingState.exemplars.length} baris dataset JSONL`;
}

function copyJsonlDataset() {
  const jsonl = generateJsonlString();
  navigator.clipboard.writeText(jsonl).then(() => {
    showToast("Dataset JSONL berhasil disalin ke clipboard!");
  }).catch(() => {
    showToast("Gagal menyalin, silakan pilih teks secara manual.");
  });
}

function downloadJsonlDataset() {
  const jsonl = generateJsonlString();
  const blob = new Blob([jsonl], { type: "application/jsonl;charset=utf-8" });
  const url = URL.createObjectURL(blob);
  const a = document.createElement("a");
  a.href = url;
  a.download = `medireflect_finetuning_dataset_${Date.now()}.jsonl`;
  document.body.appendChild(a);
  a.click();
  document.body.removeChild(a);
  URL.revokeObjectURL(url);
  showToast("File dataset JSONL berhasil diunduh!");
}

// Inisialisasi awal saat halaman termuat
document.addEventListener("DOMContentLoaded", () => {
  loadAiTrainingStorage();
  renderTrainingExemplars();
  updateJsonlPreview();
});

