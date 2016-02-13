(in-package :cl-brainfuck)
(defparameter *tape-size-default* 30000
  "The size of the tape, in bytes, used to store each byte")

(defun make-tape-array ()
  (make-array *tape-size-default*
	      :element-type 'integer
	      :initial-element 0))

(defvar *tape* (make-tape-array)
  "The tape array used to store each byte")

(defvar *brainfuck* ""
  "Place to store brainfuck code input string globally")

(define-condition open-loop-at-zero (condition) ())
(define-condition end-of-loop (condition) ())

(defparameter *operators*
  '((#\+ . +)
    (#\- . -)
    (#\, . comma)
    (#\. . period)
    (#\[ . [)
    (#\] . ])
    (#\< . <)
    (#\> . >)))

(defparameter *ascii*
  '((0 . "NULL")
    (1 . "SOH")
    (2 . "STX")	
    (3 . "ETX")	
    (4 . "EOT")	
    (5 . "ENQ")	
    (6 . "ACK")	
    (7 . "BEL")	
    (8 . "BS")	
    (9 . "HT")	
    (10 . "
");Linefeed	
    (11 . "VT")	
    (12 . "FF")	
    (13 . "CR")	
    (14 . "SO")	
    (15 . "SI")	
    (16 . "DLE")	
    (17 . "DC1")	
    (18 . "DC2")	
    (19 . "DC3")	
    (20 . "DC4")	
    (21 . "NAK")	
    (22 . "SYN")	
    (23 . "ETB")	
    (24 . "CAN")	
    (25 . "EM")	
    (26 . "SUB")	
    (27 . "ESC")	
    (28 . "FS")	
    (29 . "GS")	
    (30 . "RS")	
    (31 . "US")	
    (32 . " ")
    (33 . "!")	
    (34 . "\"")	
    (35 . "#")
    (36 . "$")	
    (37 . "%")	
    (38 . "&")	
    (39 . "'")
    (40 . "(")
    (42 . "*")	
    (43 . "+")	
    (44 . ",")	
    (45 . "-")	
    (46 . ".")	
    (47 . "/")	
    (48 . "0")	
    (49 . "1")	
    (50 . "2")	
    (51 . "3")	
    (52 . "4")	
    (53 . "5")	
    (54 . "6")	
    (55 . "7")	
    (56 . "8")	
    (57 . "9")	
    (58 . ":")
    (59 . ";")	
    (60 . "<")	
    (61 . "=")	
    (62 . ">")	
    (63 . "?")	
    (64 . "@")	
    (65 . "A")	
    (66 . "B")	
    (67 . "C")	
    (68 . "D")	
    (69 . "E")	
    (70 . "F")	
    (71 . "G")	
    (72 . "H")	
    (73 . "I")	
    (74 . "J")	
    (75 . "K")	
    (76 . "L")	
    (77 . "M")	
    (78 . "N")	
    (79 . "O")	
    (80 . "P")	
    (81 . "Q")	
    (82 . "R")	
    (83 . "S")	
    (84 . "T")	
    (85 . "U")	
    (86 . "V")	
    (87 . "W")	
    (88 . "X")	
    (89 . "Y")	
    (90 . "Z")	
    (91 . "[")	
    (92 . "\\")	
    (93 . "]")
    (94 . "^")
    (95 . "_")
    (96 . "`")	
    (97 . "a")	
    (98 . "b")	
    (99 . "c")	
    (100 . "d")	
    (101 . "e")	
    (102 . "f")	
    (103 . "g")	
    (104 . "h")	
    (105 . "i")	
    (106 . "j")	
    (107 . "k")
    (108 . "l")	
    (109 . "m")	
    (110 . "n")	
    (111 . "o")	
    (112 . "p")	
    (113 . "q")	
    (114 . "r")	
    (115 . "s")	
    (116 . "t")	
    (117 . "u")	
    (118 . "v")	
    (119 . "w")	
    (120 . "x")	
    (121 . "y")	
    (122 . "z")	
    (123 . "{")	
    (124 . "|")	
    (125 . "}")	
    (126 . "~")	
    (127 . " ")
    (128 . "Ç")	
    (129 . "ü")	
    (130 . "é")	
    (131 . "â")	
    (132 . "ä")	
    (133 . "à")	
    (134 . "å")	
    (135 . "ç")	
    (136 . "ê")	
    (137 . "ë")	
    (138 . "è")	     
    (139 . "ï")	
    (140 . "î")	
    (141 . "ì")	
    (142 . "Ä")	
    (143 . "Å")	
    (144 . "É")	
    (145 . "æ")	
    (146 . "Æ")	
    (147 . "ô")	
    (148 . "ö")	
    (149 . "ò")	
    (150 . "û")	
    (151 . "ù")	
    (152 . "ÿ")	
    (153 . "Ö")	
    (154 . "Ü")	
    (155 . "ø")	
    (156 . "£")	
    (157 . "Ø")	
    (158 . "×")	
    (159 . "ƒ")	
    (160 . "á")	
    (161 . "í")	
    (162 . "ó")	
    (163 . "ú")	
    (164 . "ñ")	
    (165 . "Ñ")	
    (166 . "ª")	
    (167 . "º")	
    (168 . "¿")	
    (169 . "®")	
    (170 . "¬")	
    (171 . "½")	
    (172 . "¼")	
    (173 . "¡")	
    (174 . "«")	
    (175 . "»")	
    (176 . "░")				
    (177 . "▒")				
    (178 . "▓")				
    (179 . "│")	
    (180 . "┤")	
    (181 . "Á")	
    (182 . "Â")	
    (183 . "À")	
    (184 . "©")	
    (185 . "╣")	
    (186 . "║")	
    (187 . "╗")	
    (188 . "╝")	
    (189 . "¢")	
    (190 . "¥")	
    (191 . "┐")	
    (192 . "└")	
    (193 . "┴")	
    (194 . "┬")	
    (195 . "├")	
    (196 . "─")	
    (197 . "┼")	
    (198 . "ã")	
    (199 . "Ã")	
    (200 . "╚")	
    (201 . "╔")	
    (202 . "╩")	
    (203 . "╦")	
    (204 . "╠")	
    (205 . "═")	
    (206 . "╬")	
    (207 . "¤")	
    (208 . "ð")	
    (209 . "Ð")	
    (210 . "Ê")	
    (211 . "Ë")	
    (212 . "È")	
    (213 . "ı")	
    (214 . "Í")	
    (215 . "Î")	
    (216 . "Ï")	
    (217 . "┘")	
    (218 . "┌")	
    (219 . "█")	
    (220 . "▄")				
    (221 . "¦")	
    (222 . "Ì")	
    (223 . "▀")				
    (224 . "Ó")	
    (225 . "ß")	
    (226 . "Ô")	
    (227 . "Ò")	
    (228 . "õ")	
    (229 . "Õ")	
    (230 . "µ")	
    (231 . "þ")	
    (232 . "Þ")	
    (233 . "Ú")	
    (234 . "Û")	
    (235 . "Ù")	
    (236 . "ý")	
    (237 . "Ý")	
    (238 . "¯")	
    (239 . "´")	
    (240 . "¬")	
    (241 . "±")	
    (242 . "‗")	
    (243 . "¾")	
    (244 . "¶")	
    (245 . "§")	
    (246 . "÷")	
    (247 . "¸")	
    (248 . "°")	
    (249 . "¨")	
    (250 . "•")	
    (251 . "¹")	
    (252 . "³")	
    (253 . "²")	
    (254 . "■")	
    (255 . "nbsp")))

(defun pointer-default () (floor (/ *tape-size-default* 2)))
(defvar *pointer* (pointer-default)
  "The pointer location for the tape. Starts near the middle.")

(defmacro byte-value ()
  `(elt *tape* *pointer*))

(defun remove-first (string)
  (if (= 1 (length string))
      ""
      (subseq string 1)))

(defmacro crement-if (operation
		      bound
		      bound-next)
  "Increment or decrement a byte"
  `(if (= (byte-value) ,bound)
      (setf (byte-value) ,bound-next)
      (,operation (byte-value))))
(defun incf-byte ()
  "Increment a byte, and wrap to 0 if 255 is incremented"
  (crement-if incf 255 0))

(defun decf-byte ()
  "Decrement a byte, and wrap to 255 if 0 is decremented"
  (crement-if decf 0 255))

(defun first-elt (string)
  (elt string 0))

(defun ascii-to-integer-aux (string-length-one ascii)
  "Ascii-to-integer recursive auxillary. Uses the string to avoid \
unprintable character mishaps."
  (let ((this (cdr (car ascii)))
	(length (length string-length-one)))
    (cond ((null ascii) nil)
	  ((or (> length 1 )
	       (< length 1)) (error "Incorrect length for string ascii"))
	  ((string-equal string-length-one this) (car (car ascii)))
	  (t (ascii-to-integer-aux string-length-one (cdr ascii))))))

(defun ascii-to-integer (char)
  (ascii-to-integer-aux (coerce (list char) 'string) *ascii*))

(defun integer-to-ascii (integer)
  (cdr (assoc integer *ascii*)))

(defun position-last-open-bracket-aux (current-position
				       depth)
  (let ((this (elt *brainfuck* current-position)))
    (if (char= #\[ this)
	(if (= 1 depth)
	    current-position
	    (if (> depth 1)
		(position-last-open-bracket-aux (1- current-position)
						(1- depth))
		(position-last-open-bracket-aux (1- current-position)
						0)))
	(if (char= #\] this)
	    (position-last-open-bracket-aux (1- current-position)
					    (1+ depth))
	    (position-last-open-bracket-aux (1- current-position)
					    depth)))))
(defun position-last-open-bracket (position)
  "Work backwards and find the matching open bracket."
  (position-last-open-bracket-aux position 0))
(defun right-shift ()
  "Move to the next byte to the \"right\""
  (setf *pointer* (1+ *pointer*)))

(defun left-shift ()
  "Move to the next byte to the \"left\""
  (setf *pointer* (1- *pointer*)))

(defun print-this-byte ()
  (format t "~a" (integer-to-ascii (byte-value))))

(defun read-this-byte ()
  (setf (byte-value)
	(ascii-to-integer (read-char))))

(defun one-off-fuck (position)
  "Run a single first brainfuck-char."
  (case (elt *brainfuck* position)
    (#\, (read-this-byte))
    (#\. (print-this-byte))
    (#\+ (incf-byte))
    (#\- (decf-byte))
    (#\] (error 'end-of-loop))
    (#\[ (if (= 0 (byte-value))
	     (error 'open-loop-at-zero)))
    (#\> (right-shift))
    (#\< (left-shift))))

(defun skip-loop-aux (position depth)
  (let ((this (elt *brainfuck* position)))
    (if (char= #\[ this)
	(skip-loop-aux (1+ position) (1+ depth))
	(if (char= #\] this)
	    (if (= 1 depth)
		(1+ position)
		(skip-loop-aux (1+ position) (1- depth)))
	    (skip-loop-aux (1+ position) depth)))))

(defun skip-loop (position)
  (skip-loop-aux position 0))

(defun interpret-fuck-aux (position)
  (loop
     until (= (length *brainfuck*) position)
     do (handler-case (one-off-fuck position)
	  (end-of-loop () (setf position
				(1- (position-last-open-bracket position))))
	  (open-loop-at-zero () (setf position
				      (1- (skip-loop position)))))
     do (setf position (1+ position))))

(defun interpret (brainfuck-string)
  "Interpret the brainfuck"
  (setf *tape* (make-tape-array))	  ;Don't use this dynamic variable either
  (setf *brainfuck* brainfuck-string)
  (setf *pointer* (pointer-default))
  (interpret-fuck-aux 0)
  nil)
