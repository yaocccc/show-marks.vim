hi Marks ctermfg=80
let s:mark_ns_id = get(g:, 'mark_ns_id', 9898)
let s:mark_priority = get(g:, 'mark_priority', 999)
let s:enabled_marks = get(g:, 'enabled_marks', '[a-zA-Z]')

func! s:getMarks()
    let marks = getmarklist(bufname())
    let marks = filter(marks, 'v:val.mark[1] =~# s:enabled_marks')
    let marksByLnum = {}
    for m in marks
        let mark = m.mark[1]
        let lnum = m.pos[1]
        let marksOflnum = get(marksByLnum, lnum, [])
        let marksOflnum = marksOflnum + [mark]
        let marksByLnum[lnum] = marksOflnum
    endfor
    return marksByLnum
endf

func! s:showMarks(...)
    call sign_unplace('*', {'id': s:mark_ns_id})
    let bufnr = bufnr()
    if bufname() == "" || !buflisted(bufnr) | return | endif
    let marksByLnum = s:getMarks()
    for lnum in keys(marksByLnum)
        let text = join(marksByLnum[lnum], '')
        if len(text) > 2 | let text = marksByLnum[lnum][0] . '…' | endif
        call sign_define('mark_' . text, {'text': text, 'texthl': 'Marks'})
        call sign_place(s:mark_ns_id, '', 'mark_' . text, bufnr, {'lnum': lnum, 'priority': s:mark_priority})
    endfor
endf

noremap <unique> <script> \sm m
noremap <silent> m :exe 'norm \sm'.nr2char(getchar())<bar>call <SID>showMarks()<CR>
au WinEnter,BufWinEnter,CursorHold * call <SID>showMarks()
