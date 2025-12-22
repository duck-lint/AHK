#Requires AutoHotkey v2.0
#SingleInstance Force

; ╭──────────────────────────────────────────────────────────╮
; │  Default: type -> or \alpha → you get the pretty symbol  │
; │  When you need raw LaTeX instead, type ;;to or ;;alpha   │
; ╰──────────────────────────────────────────────────────────╯

; ── English shortcuts────────────────────────────
::b/c::because
::b/w::between
::w/::with
::w/o::without
::w/r/t::with respect to
::i.e.::i.e.
::e.g.::e.g.
::etc.::etc.
::tbh::to be honest
::imo::in my opinion
::idk::I don't know
::afaik::as far as I know
::btw::by the way
::obv::obviously
::prob::probably
::def::definitely
::bc::because          ; even shorter!
::tho::though
::thru::through
::ur::your / you're   ; contextually smart people just live with it
::arent::aren't
::dont::don't
::didnt::didn't
::cant::can't
::wont::won't
::theres::there's
::theyre::they're
::thats::that's
::its::it's
::ill::I'll
::im::I'm
::ive::I've
::isnt::isn't
::youre::you're
::wasnt::wasn't
:*?:---::—
::addr::address
::rec::receive / recommendation / record
::sched::schedule
::approx::approximately
::info::information
::prob::problem / probability
::sol::solution
::eqn::equation
::fig::figure
::ref::reference
::avg::average
::prayge::🙏
::psr::Principle of Sufficient Reason
::4fr::4-Fold Root
::alr::already
::schopp::Schopenhauer
::schopps::Schopenhauer's
::kno::know
::;dr::Dream Recall:
::;ydr::Y-Day Review:
::;di::Daily Intent:
::incl::including
::mgmt::management
::havent::haven't
::i::I
::yday::yesterday
::re;::regarding
::;ffj::Freeform Journaling:
::;tj::Trading Journal:
::shes::she's
::hes::he's
::qm::quantum mechanics
::hers::her's
::incl::including
::noti::notification
::wd::Work Day
:::)::🙂
:::D::😃
::100p::💯
::tu::👍
::lets::let's
::doesnt::doesn't
::yt::YouTube
::jan::January
::feb::February
::mar::March
::aug::August
::sept::September
::oct::October
::nov::November
::dec::December
::mon::Monday
::tues::Tuesday
::wed::Wednesday
::thur::Thursday
::fri::Friday
::satur::Saturday
::sund::Sunday

; ──────────────────────────────────────────────────────────────
; RELOAD AHK
; ──────────────────────────────────────────────────────────────

^!r:: { ;        Ctrl+Alt+R
    Reload
    return
}

; ── other fun things ─────────────────────────────────────
::;d::
{
    formatted := FormatTime(A_Now, "yyyy-MM-dd")
    Send formatted
}

::;t::
{
    formatted := FormatTime(A_Now, "HH:mm")
    Send formatted
}

::;dt::
{
    formatted := FormatTime(A_Now, "yyyy-MM-dd HH:mm:ss")
    Send formatted
}

::;now::
{
    formatted := FormatTime(A_Now, "dddd, MMMM d, yyyy 'at' h:mm tt")
    Send formatted
}

; ──────────────────────────────────────────────────────────────
; LaTeX highlighted text
; ──────────────────────────────────────────────────────────────

^+m:: {                                     ; Ctrl+Shift+M → make LaTeX-friendly math text
    saved := ClipboardAll()                 ; backup full clipboard (all formats)

    ; Copy current selection
    A_Clipboard := ""                       ; clear to detect the new copy
    Send "^c"
    if !ClipWait(0.3) {                     ; wait up to 0.3s for clipboard to fill
        Clipboard := saved                  ; restore if nothing copied
        return
    }

    ; Transform: replace spaces with "\ "
    text := A_Clipboard
    text := StrReplace(text, " ", "\ ")

    ; Wrap in $...$
    A_Clipboard := "$" . text . "$"

    ; Paste back over the selection
    Send "{Blind}^v"

    ; Restore original clipboard
    Clipboard := saved
}

; ──────────────────────────────────────────────────────────────
; Clipboard text transformers – works on selected text anywhere
; ──────────────────────────────────────────────────────────────

^+u:: {                                      ; Ctrl+Shift+U → UPPERCASE
    saved := ClipboardAll()
    A_Clipboard := StrUpper(A_Clipboard)
    A_Clipboard := StrUpper(A_Clipboard)
    Send "{Blind}^v"
    Clipboard := saved
    saved := ""
}

^+l:: {                                      ; Ctrl+Shift+L → lowercase
    saved := ClipboardAll()
    A_Clipboard := StrLower(A_Clipboard)
    Send "{Blind}^v"
    Clipboard := saved
    saved := ""
}

^+t:: {                                      ; Ctrl+Shift+T → Title Case
    saved := ClipboardAll()
    A_Clipboard := StrTitle(A_Clipboard)
    Send "{Blind}^v"
    Clipboard := saved
    saved := ""
}

^+c:: {                                      ; Ctrl+Shift+C → Capitalize Each Word
    saved := ClipboardAll()
    A_Clipboard := RegExReplace(A_Clipboard, "(\w)([\w']*)", "$U1$L2")
    Send "{Blind}^v"
    Clipboard := saved
    saved := ""
}

; ── Arrows ─────────────────────────────────────
::-->::→
::<--::←
::<->::↔
::=>::⇒
::==>::⟹
::<=::≤
::>=::≥
::<=>::⇔

; ── Common math ───────────────────────────────
::!=::≠
::~~::≈
::+-::±
::inf::∞
::sum::∑
::prod::∏
::int::∫
::oint::∮
::;partial::∂
::nabla::∇
::sqrt::√
::;*::·
::xx::×  ; because ::xx:: is easier than ::*::
::/...::÷

; ── Sets & logic ─────────────────────────────
::inin::∈
::nin::∉
::subb::⊂
::sup::⊃
::sube::⊆
::supe::⊇
::empty::∅
::cap::∩
::cup::∪
::forall::∀
::exists\::∃
::therefore\::∴
::because\::∵

; ── Greek lowercase (most common ones) ───────
::alpha::α
::beta::β
::gamma::γ
::delta::δ
::epsilon::ε
::zeta::ζ
::eta::η
::theta::θ
::kappa::κ
::lambda::λ
::mu::μ
::nu::ν
::xi::ξ
::pi::π
::rho::ρ
::sigma::σ
::tau::τ
::phi::φ
::chi::χ
::psi::ψ
::omega::ω

; ── Greek uppercase ──────────────────────────
::Gamma::Γ
::Delta::Δ
::Theta::Θ
::Lambda::Λ
::Xi::Ξ
::Pi::Π
::Sigma::Σ
::Phi::Φ
::Psi::Ψ
::Omega::Ω

; ── Raw LaTeX fallback (type two semicolons first) ──
;;to::\to
;;alpha::\alpha
;;beta::\beta
;;gamma::\gamma
;;delta::\delta
;;theta::\theta
;;lambda::\lambda
;;pi::\pi
;;sigma::\sigma
;;phi::\phi
;;psi::\psi
;;omega::\omega
;;infty::\infty
;;sum::\sum
;;int::\int
;;partial::\partial
;;nabla::\nabla
;;approx::\approx
;;neq::\neq
;;leq::\leq
;;geq::\geq
;;subseteq::\subseteq
;;in::\in