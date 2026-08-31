# Professional Locker Password Generator

**Personal PowerShell Project**

I was bored, so I made this little personal project to generate the
password for my professional locker from my laptop wallpaper.

The idea is to turn a designated laptop wallpaper into a
deterministic four-digit value and then represent that value as a
SHA-256 hash.

The wallpaper itself is deliberately **not included** in this project.

## How to use it

Put `wallpaper-fingerprint.ps1` in the same folder as the workplace
wallpaper.

For example:

```text
My Folder/
├── wallpaper-fingerprint.ps1
└── background.jpg
```

Then run:

```powershell
.\wallpaper-fingerprint.ps1
```

The script automatically searches **the folder containing the script**
for image files.

It displays the available images as a numbered list, so there is no
need to enter an absolute file path.

Example:

```text
IMAGE SELECTION
------------------------------------------------------------

Select the image you want to analyse.
Only image files in this script's folder are listed.

  [1] background.jpg
  [2] holiday.jpg
  [3] test.png

Enter the number of the image: 1
```

## What the script does

The script:

1. Finds image files in its own folder.
2. Lets you select one by number.
3. Reads the selected image's underlying file data.
4. Generates a deterministic image fingerprint.
5. Derives a four-digit locker password from that fingerprint.
6. Calculates the SHA-256 hash of that four-digit password.
7. Displays the resulting hash.

The intended process is:

```text
workplace wallpaper
        ↓
image fingerprint
        ↓
four-digit locker password
        ↓
SHA-256
        ↓
locker password hash
```

## Output

The final output is displayed as:

```text
MY PROFESSIONAL LOCKER PASSWORD, HASHED WITH SHA-256:

<sha-256 digest>
```

## SHA-256

SHA-256 is a cryptographic hash function, not an encryption algorithm.
The resulting digest cannot simply be decrypted.

Because the underlying locker password is only four digits, the original
value can nevertheless be recovered by testing the 10,000 possible
four-digit values and comparing their SHA-256 hashes.

## Requirements

- Windows
- PowerShell 5.1 or later
- An image file in the same folder as the script

Supported image formats:

- JPG / JPEG
- PNG
- BMP
- GIF
- TIFF

## Project status

Personal experiment.

This is not intended to provide cryptographic protection for real
passwords. It is simply a personal project for experimenting with
deterministic image fingerprints, four-digit values and SHA-256.
