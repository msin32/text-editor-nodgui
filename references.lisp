;;excerpts from nodgui demo for reference
(defun demo-notebook (&key theme)
  (with-nodgui (:theme theme)
    (let* ((nb (make-instance 'notebook))
           (f1 (make-instance 'frame :master nb))
           (f2 (make-instance 'frame :master nb))
           (t1 (make-instance 'text :master f1 :width 40 :height 10))
           (b1 (make-instance 'button :master f1 :text "Press me"
                              :command (lambda ()
                                         (format t "the index is:~a~%" (notebook-index nb f1))
                                         (finish-output))))
           (b2 (make-instance 'button :master f2 :text "A button"
                              :command (lambda ()
                                         (format t "the index is:~a~%" (notebook-index nb f2))
                                         (finish-output)))))
      (pack nb :fill :both :expand t)
      (pack t1 :fill :both :expand t)
      (pack b1 :side :top)
      (pack b2 :side :top)
      (notebook-add nb f1 :text "Frame 1")
      (notebook-add nb f2 :text "Frame 2")
      (notebook-tab nb f2 :text "Frame 2 (changed after adding)")
      (notebook-enable-traversal nb)
      (append-text t1 "Foo [Bar] {Baz}"))))

(defun demo-menu-check-buttons ()
  (with-nodgui ()
    (let* ((mb (make-menubar))
           (mfile (make-menu mb "File" ))
           (medit (make-menu mb "Edit"))
           (ck-1 (make-instance 'menucheckbutton
                                :master mfile
                                :text "Check 1"))
           (button (make-instance 'button
                                  :text "get menu button value"
                                  :command
                                  (lambda ()
                                    (message-box (format nil
                                                         "check-value ~a"
                                                         (value ck-1))
                                                 "info"
                                                 +message-box-type-ok+
                                                 +message-box-icon-info+)))))
      (pack button))))
