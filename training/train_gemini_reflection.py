#!/usr/bin/env python3
"""
================================================================================
Medireflect AI — Automated Fine-Tuning Pipeline for Google Gemini 1.5
Berdasarkan Standar Pedagogis Medis AMEE Guide No. 44 (Sandars, 2009)
================================================================================
Skrip ini mengunggah dataset kurasi klinis (JSONL) dan memulai proses
Supervised Fine-Tuning (SFT) pada model Gemini 1.5 Flash untuk menghasilkan
mentor reflektif kedokteran yang empatik, terstruktur Gibbs, dan bebas bias asesmen.
"""

import os
import sys
import json
import time
import argparse

def validate_jsonl_file(filepath):
    """Validasi format dataset JSONL sebelum diunggah ke Google Cloud."""
    print(f"[*] Memeriksa format integritas dataset: {filepath}")
    if not os.path.exists(filepath):
        print(f"[!] Error: File dataset tidak ditemukan di {filepath}")
        return False, 0

    valid_rows = 0
    with open(filepath, "r", encoding="utf-8") as f:
        for idx, line in enumerate(f, 1):
            line = line.strip()
            if not line:
                continue
            try:
                data = json.loads(line)
                if "messages" not in data:
                    print(f"[!] Baris {idx} tidak memiliki atribut 'messages'.")
                    return False, valid_rows
                roles = [m.get("role") for m in data["messages"]]
                if not ("user" in roles and "model" in roles):
                    print(f"[!] Baris {idx} harus memiliki pesan bertipe 'user' dan 'model'.")
                    return False, valid_rows
                valid_rows += 1
            except json.JSONDecodeError as e:
                print(f"[!] Error sintaks JSON pada baris {idx}: {e}")
                return False, valid_rows

    print(f"[+] Validasi sukses: {valid_rows} pasangan dialog klinis siap digunakan.")
    return True, valid_rows

def run_fine_tuning(api_key, dataset_path, model_name, epochs):
    """Jalankan proses fine-tuning menggunakan Google Generative AI SDK."""
    try:
        import google.generativeai as genai
    except ImportError:
        print("[!] Library 'google-generativeai' belum terpasang.")
        print("[*] Pasang dengan perintah: pip install google-generativeai")
        return

    genai.configure(api_key=api_key)

    print("\n=======================================================")
    print("🚀 MEMULAI PIPELINE TRAINING MEDIREFLECT AI")
    print("=======================================================")
    print(f"• Base Model   : gemini-1.5-flash-001")
    print(f"• Target Name  : {model_name}")
    print(f"• Dataset      : {dataset_path}")
    print(f"• Epochs       : {epochs}")
    print("=======================================================\n")

    # Inisialisasi proses tuning
    print("[1/4] Mengunggah dataset ke Google AI Studio Storage...")
    try:
        # Load training dataset
        training_data = []
        with open(dataset_path, "r", encoding="utf-8") as f:
            for line in f:
                if line.strip():
                    training_data.append(json.loads(line.strip()))

        print(f"[2/4] Menyiapkan payload training ({len(training_data)} samples)...")
        print("[3/4] Mendaftarkan job fine-tuning pada klaster Google Cloud TPU...")
        
        # Panggilan API Fine-Tuning resmi
        operation = genai.create_tuned_model(
            source_model="models/gemini-1.5-flash-001",
            training_data=training_data,
            id=model_name,
            epoch_count=epochs,
            batch_size=4,
            learning_rate=0.001,
            description="Medireflect AI - Mentor Reflektif Klinis Kedokteran (AMEE Guide 44)",
        )

        print(f"[+] Job pelatihan berhasil dibuat! Nama Model: tunedModels/{model_name}")
        print("[4/4] Memantau progres komputasi bobot (loss convergence)...")

        # Polling status tuning
        for status in operation.wait_bar():
            time.sleep(10)

        result = operation.result()
        print("\n🎉 PELATIHAN SELESAI DENGAN SUKSES!")
        print(f"Nama Model Aktif: {result.name}")
        print("Model kustom ini sekarang siap digunakan langsung di aplikasi Medireflect AI.")
        
    except Exception as e:
        print(f"\n[!] Catatan Eksekusi API: {e}")
        print("\n💡 Panduan Alternatif (Tanpa Koding):")
        print("Anda dapat mengunggah file 'medireflect_finetuning_dataset.jsonl' langsung")
        print("ke Google AI Studio web interface di https://aistudio.google.com/ -> 'Tuning'")
        print("untuk melatih model hanya dengan klik mouse tanpa konfigurasi terminal!")

def main():
    parser = argparse.ArgumentParser(description="Medireflect AI Fine-Tuning CLI")
    parser.add_argument(
        "--api-key",
        default=os.environ.get("GEMINI_API_KEY", ""),
        help="Google Gemini API Key (atau set environment variable GEMINI_API_KEY)",
    )
    parser.add_argument(
        "--dataset",
        default="medireflect_finetuning_dataset.jsonl",
        help="Path ke file dataset JSONL",
    )
    parser.add_argument(
        "--model-name",
        default=f"medireflect-mentor-v1",
        help="ID nama unik untuk model kustom hasil pelatihan",
    )
    parser.add_argument(
        "--epochs",
        type=int,
        default=5,
        help="Jumlah epoch iterasi pelatihan (default: 5)",
    )

    args = parser.parse_args()

    # Cek direktori lokal jika relative path
    dataset_file = args.dataset
    if not os.path.isabs(dataset_file) and not os.path.exists(dataset_file):
        script_dir = os.path.dirname(os.path.abspath(__file__))
        candidate = os.path.join(script_dir, dataset_file)
        if os.path.exists(candidate):
            dataset_file = candidate

    valid, count = validate_jsonl_file(dataset_file)
    if not valid:
        sys.exit(1)

    if not args.api_key:
        print("\n[!] API Key Google Gemini belum diberikan.")
        print("    Contoh pemanggilan:")
        print(f"    python {os.path.basename(__file__)} --api-key AIzaSyYourKeyHere")
        print("    Atau buka file 'PANDUAN_TRAINING_AI.md' untuk panduan visual di browser.")
        sys.exit(0)

    run_fine_tuning(args.api_key, dataset_file, args.model_name, args.epochs)

if __name__ == "__main__":
    main()
