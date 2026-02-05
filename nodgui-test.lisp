(ql:quickload :nodgui)
(ql:quickload :uiop) ; this causes a conflict with create-image, emptyp
(ql:quickload :str)
;; (in-package :nodgui)
(in-package :cl-user)
(defpackage :nodgui-editor
	    (:use :cl :nodgui :uiop :str))
(in-package :nodgui-editor)

;;utility functions
(defun subdirectory-names (dir)
  ;; DIR is a pathname for a directory, e.g. #P"/path/to/root/"
  (let* ((pattern (merge-pathnames #P"*/" dir))
         (subdirs (directory pattern)))
    (mapcar (lambda (p)
              (car (last (pathname-directory p))))
            subdirs)))

(defun find-basenames (dir base)
  (labels ((walk (path)
             (let* ((pattern (merge-pathnames "*.*" path))
                    (entries (directory pattern)))
               (loop for p in entries
                     if (and (pathname-type p)
                             (string-equal (pathname-type p) base))
                       collect (pathname-name p)
                     else if (and (pathname-directory p)
                                  (null (pathname-type p))) ; directory
                       append (walk (merge-pathnames #P"*/" p))))))
    (walk dir)))

(defun basenames-in-subdirs (root-dir base)
  "ROOT-DIR is a pathname designating a directory, e.g. #P\"/root/\"."
  (let* ((subdir-pattern (merge-pathnames #P"*/" root-dir))
         (subdirs (directory subdir-pattern)))
    (loop for subdir in subdirs
          append
            (let* ((txt-pattern (merge-pathnames base subdir))
                   (txt-files (directory txt-pattern)))
              (mapcar #'pathname-name txt-files)))))

;;initialization
(setq current-file nil
      ;;there isn't an existing way to check these locations to see if themes are valid.
      ;;will need a procedure that checks if theme valid first before adding to list
      themes (basenames-in-subdirs nodgui:*themes-directory* #P"*.tcl"))

;;listbox attempt (fail)
(defun text-editor-listboxes ()
    (with-nodgui ()
      (let* ((mb (make-menubar))
	     (mfile (make-menu mb "File"))
	     (mview (make-menu mb "View"))
	     (medit (make-menu mb "Edit"))
	     (fmenu (make-instance 'listbox :master mfile))
	     (t1 (make-instance 'text)))
    (pack t1)
    (listbox-append fmenu '("New"))
    (listbox-append fmenu '("Open")))))

;;main implementation
(defun main-editor ()
  (with-nodgui (:title window-title :theme "yaru") ;TODO: update window-title dynamically
    (setq current-file nil
	  window-title "*scratch*")
    (let* ((root (root-toplevel))
	 (mb (make-menubar))
	 (t1 (make-instance 'text))
	 (mfile (make-menu mb "File"))
	 (medit (make-menu mb "Edit"))
	 (msel (make-menu mb "Selection"))
	 (mview (make-menu mb "View"))
	 (msett (make-menu mb "Settings"))
	 (mhelp (make-menu mb "Help"))
	 ;;TODO: macro to streamline these entries
	 (mfnew (make-menubutton mfile "New" (lambda ()
					       (format t "pressed New")
					       (setq current-file nil
						     window-title "*scratch*") ;I don't think its possible to change title after being set, would have to make new window and close old one
					       (clear-text t1))))
	 (mfopen (make-menubutton mfile "Open" (lambda ()
						 (format t "pressed Open")
						 (let ((file (get-open-file)))
						   (setq current-file file
							 window-title file)
						   (clear-text t1)
						   (insert-text t1 (uiop:read-file-string file))))))
	 (mfsave (make-menubutton mfile "Save" (lambda ()
						 (format t "pressed Save")
						 (if current-file
						     (progn (format t "File exists, saving")
							    (str:to-file current-file (text t1)))
						     (progn
						       (format t "File does not exist yet, saving as")
						       ;; (format t "t1: ~a ~a" t1 (text t1)) ;debug
						       (let ((file (get-save-file)))
							 (with-open-file (stream file :if-exists :supersede
										      :direction :output)
							   (format stream "~a" (text t1)))
							 (setq current-file file
							       window-title file)))))))
	 (mfsaveas (make-menubutton mfile "Save As" (lambda ()
						 (format t "pressed Save As")
						 (let ((file (get-save-file)))
							 (with-open-file (stream file :if-exists :supersede
										      :direction :output)
							   (format stream "~a" (text t1)))
						   (setq current-file file
							 window-title file)))))
	 (msthemes (make-menubutton msett "Themes" (lambda ()
					       (format t "pressed Themes")
						     (let ((chosen (nodgui.mw:listbox-dialog
								    (root-toplevel)
								    "listbox dialog"
								    "Choose a theme"
								    themes)))
						       (use-theme (string (car chosen))))
						     )))
	 )
    (pack t1 :fill :both :expand t))
  ))

;;initialize
(setq current-file nil
      window-title "*scratch*")
(main-editor)
