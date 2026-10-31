# Publication authorization and release workflow

DPA-BUILD-04 explicitly authorizes public publication of the audited foundation and successive verified mathematical increments. This authorization supersedes the earlier pending-publication state. The constitution remains proposed; publication is not adoption.

The current release includes the constitution, newly authored mathematics/code, proof and source records, 42 baseline problems, ten original frontier files, roadmap, analytical dossiers and documentation. Original sensitive/copyrighted attachments and private archive contents are excluded individually in verification/disclosure-audits/EXCLUSIONS.json. Derived mathematical metadata is retained with provenance.

New Atlas source and owner-supplied release documents use Apache-2.0; third-party notices and licenses remain controlling. There is no blanket relicensing of private source or external works.

For each release: run scripts/reproduce.py, verify pinned source records, inspect source and disclosure scans, update the content manifest, commit, push the authorized branch without force, and compare remote SHA to local SHA. Record tag/branch publication only after success. Source-reported claims and incomplete dossier/experimental work remain marked incomplete.
