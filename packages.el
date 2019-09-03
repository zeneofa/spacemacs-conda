;;; packages.el --- conda layer packages file for Spacemacs.
;;
;; Copyright (c) 2012-2018 Sylvain Benner & Contributors
;;
;; Author:  <jq2@LAP114831>
;; URL: https://github.com/syl20bnr/spacemacs
;;
;; This file is not part of GNU Emacs.
;;
;;; License: GPLv3

;;; Commentary:

;; See the Spacemacs documentation and FAQs for instructions on how to implement
;; a new layer:
;;
;;   SPC h SPC layers RET
;;
;;
;; Briefly, each package to be installed or configured by this layer should be
;; added to `conda-packages'. Then, for each package PACKAGE:
;;
;; - If PACKAGE is not referenced by any other Spacemacs layer, define a
;;   function `conda/init-PACKAGE' to load and initialize the package.

;; - Otherwise, PACKAGE is already referenced by another Spacemacs layer, so
;;   define the functions `conda/pre-init-PACKAGE' and/or
;;   `conda/post-init-PACKAGE' to customize the package as it is loaded.

;;; LAYER for the elpa package conda.el https://github.com/necaris/conda.el

(defconst conda-packages
  '(
    conda 
    )
  )

;; utility function to emulate getting the directory path
(defun dirname (path)
  (directory-file-name (file-name-directory path))
  )

(defun conda/init-conda ()
  (use-package conda
    :defer t
    :init
      (progn
        ;; set the conda-anaconda-home variable for a windows system
        (if (string-equal system-type "windows-nt")
          (setq conda-anaconda-home (file-name-as-directory (dirname (dirname (executable-find "conda.exe")))))
          (setq conda-anaconda-home (file-name-as-directory (dirname (dirname (executable-find "conda"))))))

        ;; declare the spacemacs prefix
        (spacemacs/declare-prefix "ae" "environment-conda")

        ;; declare spacemacs keybindings
        (spacemacs/set-leader-keys
          "aea" 'conda-env-activate
          "aed" 'conda-env-deactivate
          "aeb" 'conda-env-activate-for-buffer)


          )
    :config
    (progn

      ;; add the ability to call the base anaconda environment
      ;; TODO: add a check for the validity of this environment
      (defun conda-env-candidates ()
        "Fetch all the candidate environments. Overwriting the original function in conda.el to allow for a base environment."
        (let ((candidates (conda-env-candidates-from-dir (conda-env-default-location))))
          (add-to-list 'candidates "base")
          (when (not (eq (length (-distinct candidates))
                          (length candidates)))
            (error "Some envs have the same name!"))
          candidates))

      ;; add the ability to resolve the "base" environment to its path
      (defun conda-env-name-to-dir (name)
        "Translate NAME to the directory where the environment is located. Overwriting the original function in conda.el, to allow for the base function to resolve."
        (if (string-equal name "base")
            (expand-file-name conda-anaconda-home)
          (let* ((default-location (file-name-as-directory (conda-env-default-location)))
                  (initial-possibilities (list name (concat default-location name)))
                  (possibilities (if (boundp 'venv-location)
                                    (if (stringp 'venv-location)
                                        (cons venv-location initial-possibilities)
                                      (nconc venv-location initial-possibilities))
                                  initial-possibilities))
                  (matches (-filter 'conda--env-dir-is-valid possibilities)))
            (if (> (length matches) 0)
                (expand-file-name (car matches))
              (error "No such conda environment: %s" name)))))

      )
  )
)
;;; packages.el ends here
