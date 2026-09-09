# Panduan Pelatihan & Kalibrasi AI: MEDIREFLECT AI
### Berdasarkan Standar Pedagogis Medis AMEE Guide No. 44 (Sandars, 2009) & Siklus Gibbs (1988)

Dokumen ini menjelaskan secara menyeluruh bagaimana cara melatih (*training*), mengkalibrasi (*prompt calibration*), dan melakukan *fine-tuning* pada model kecerdasan buatan **Medireflect AI** agar memiliki empati tinggi, mampu merangsang pemikiran kritis (*Supportive Challenge*), dan tidak menghakimi mahasiswa kedokteran (*Zero Assessment Tension*).

---

## 1. Mengapa AI Refleksi Kedokteran Harus Dilatih Khusus?

Model AI generik (seperti ChatGPT atau Gemini mentah) cenderung bertindak seperti **penguji klinis (asesor ujian)** atau **ensiklopedia medis berjalan**. Ketika mahasiswa kedokteran curhat tentang kesalahannya di bangsal (misal: gagal infus anak atau dimarahi konsulen), AI biasa sering memberi kuliah teknis atau menceramahi mahasiswa.

Menurut **AMEE Guide No. 44**:
1. **Refleksi Menuntut Rasa Aman Emosional:** Mahasiswa tidak akan berani jujur jika mereka merasa sedang dinilai atau dihakimi (*Assessment Tension*).
2. **Prinsip *Supportive Challenge*:** Mentor harus memvalidasi emosi mahasiswa terlebih dahulu (*Support*), baru kemudian menantang asumsi bawah sadarnya (*Challenge*).
3. **Pematuhan Siklus Gibbs 6 Fase:** Pembimbingan harus memandu mahasiswa secara sistematis:
   `Deskripsi ➔ Perasaan ➔ Evaluasi ➔ Analisis ➔ Kesimpulan ➔ Rencana Aksi (SMART)`.

---

## 2. Tiga Pilihan Cara Melatih AI

### Pilihan A: Pelatihan In-App via Aplikasi (Paling Mudah & Instan)
> **Cocok untuk:** Dokter Pendidik Klinis (DPJP), Dosen FK, atau Mahasiswa tanpa keahlian teknis.

1. Buka aplikasi **Medireflect AI** (di Flutter mobile atau Web Simulator).
2. Buka menu **Profil** ➔ klik **Studio Pelatihan AI (Mode Edukator)** (atau klik tombol cepat di sidebar simulator).
3. Pada tab **Persona & Kalibrasi**:
   - Geser slider **Skala Empati** (misal: 4.8 untuk stase emosional seperti Paliatif/Jiwa).
   - Geser slider **Tantangan Sokratik** (misal: 4.2 untuk memicu telaah kritis).
   - Klik **Simpan Kalibrasi**.
4. Pada tab **Bank Kasus (Exemplars)**:
   - Tambahkan contoh kasus spesifik di RS Anda (contoh: *"Pasien Menolak Tindakan Operasi"*).
   - Masukkan respons ideal yang Anda inginkan.
5. Pada tab **Playground**: Uji kalimat curhat mahasiswa dan lihat respons AI secara *realtime*!

---

### Pilihan B: Fine-Tuning No-Code di Google AI Studio (Gratis)
> **Cocok untuk:** Menghasilkan model permanen `tunedModels/medireflect-custom-v1` langsung di cloud Google tanpa instalasi Python.

1. Buka browser dan kunjungi: **[https://aistudio.google.com/](https://aistudio.google.com/)**.
2. Login menggunakan Akun Google Anda.
3. Pada menu navigasi sebelah kiri, klik **"Tuned Models"** (atau **"Create Tuned Model"**).
4. Pilih Base Model: **`Gemini 1.5 Flash`**.
5. Pada bagian upload dataset, klik **"Import"** dan pilih file:
   📁 `c:\Users\Administrator\REFLECTMED AI\training\medireflect_finetuning_dataset.jsonl`
6. Beri nama model, contoh: `medireflect-indonesia-v1`.
7. Klik **"Tune"**. Tunggu proses training di server TPU Google selama ~5-10 menit.
8. Setelah selesai, Anda akan mendapatkan ID Model (misal: `tunedModels/medireflect-indonesia-v1`).
9. Masukkan ID Model ini ke dalam aplikasi Medireflect AI!

---

### Pilihan C: Fine-Tuning Otomatis via Terminal Python
> **Cocok untuk:** Administrator IT Fakultas Kedokteran atau peneliti *Medical Education*.

Kami telah menyertakan skrip otomatisasi di folder `training/`.

1. Pastikan Anda memiliki Python 3.9+ dan pasang dependensi:
   ```bash
   pip install google-generativeai
   ```
2. Jalankan skrip pelatihan dengan API Key Anda:
   ```bash
   python training/train_gemini_reflection.py --api-key AIzaSyContohKeyAnda123 --epochs 5
   ```
3. Skrip akan secara otomatis:
   - Memvalidasi seluruh format JSONL.
   - Mengunggah data ke klaster Google Cloud TPU.
   - Memantau grafik konvergensi (*loss curves*).
   - Mengeluarkan model siap pakai.

---

## 3. Format Dataset Pembelajaran (.JSONL)

Setiap baris di dalam file `medireflect_finetuning_dataset.jsonl` mengikuti standar resmi Gemini & OpenAI:

```json
{
  "messages": [
    {
      "role": "system",
      "content": "Anda adalah REFLECTMED AI, Mentor Klinis Reflektif berstandar AMEE Guide No. 44..."
    },
    {
      "role": "user",
      "content": "[Stase Pediatri - Kasus Gagal Infus]\nDok, tadi di bangsal anak aku gagal pasang infus balita..."
    },
    {
      "role": "model",
      "content": "Perasaan bersalah dan ragu pada diri sendiri itu sangat wajar dialami setiap dokter..."
    }
  ]
}
```

---

## 4. Parameter Evaluasi Keberhasilan Model

Setelah pelatihan, lakukan pengujian dengan 3 kriteria keberhasilan:
1. **Validasi Emosi (Fase Feelings):** AI tidak langsung mendebat atau menyalahkan mahasiswa, melainkan mengakui beban mentalnya terlebih dahulu.
2. **Kedalaman Metakognitif (Reflection Depth):** Mampu mengantarkan mahasiswa dari level *Superficial (Deskriptif)* ke level *Analytical* atau *Transformative*.
3. **Rencana Aksi SMART:** Menutup sesi dengan komitmen tindakan konkret terukur sebelum jadwal jaga berikutnya.
