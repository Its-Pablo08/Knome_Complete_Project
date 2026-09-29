import React, { useState, useEffect, useRef } from 'react';

const MONTH_NAMES = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December'
];

const DAYS_SHORT = ['Su', 'Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa'];

export default function CustomDateTimePicker({
    value,
    onChange,
    onConfirm,
    onCancel,
    onClear
}) {
    // Parse incoming value or default to current date + 15 mins
    const parseInitialDate = () => {
        if (value) {
            const d = new Date(value);
            if (!isNaN(d.getTime())) return d;
        }
        return new Date(Date.now() + 15 * 60000);
    };

    const initial = parseInitialDate();
    const [viewYear, setViewYear] = useState(initial.getFullYear());
    const [viewMonth, setViewMonth] = useState(initial.getMonth()); // 0-11
    const [selectedDate, setSelectedDate] = useState(initial.getDate());

    // 12-hour format state
    const rawHours = initial.getHours();
    const [selectedHour, setSelectedHour] = useState(rawHours % 12 || 12);
    const [selectedMinute, setSelectedMinute] = useState(initial.getMinutes());
    const [selectedAmPm, setSelectedAmPm] = useState(rawHours >= 12 ? 'PM' : 'AM');

    const hoursColRef = useRef(null);
    const minsColRef = useRef(null);

    // Sync state if external value changes
    useEffect(() => {
        if (value) {
            const d = new Date(value);
            if (!isNaN(d.getTime())) {
                setViewYear(d.getFullYear());
                setViewMonth(d.getMonth());
                setSelectedDate(d.getDate());
                const h = d.getHours();
                setSelectedHour(h % 12 || 12);
                setSelectedMinute(d.getMinutes());
                setSelectedAmPm(h >= 12 ? 'PM' : 'AM');
            }
        }
    }, [value]);

    // Auto-scroll selected hour and minute into center view on mount
    useEffect(() => {
        const timer = setTimeout(() => {
            if (hoursColRef.current) {
                const sel = hoursColRef.current.querySelector('[data-selected="true"]');
                if (sel) sel.scrollIntoView({ block: 'center', behavior: 'smooth' });
            }
            if (minsColRef.current) {
                const sel = minsColRef.current.querySelector('[data-selected="true"]');
                if (sel) sel.scrollIntoView({ block: 'center', behavior: 'smooth' });
            }
        }, 80);
        return () => clearTimeout(timer);
    }, []);

    // Construct standard ISO string (YYYY-MM-DDTHH:mm)
    const computeDateTimeString = (y, m, d, h12, min, ampm) => {
        let h24 = h12 % 12;
        if (ampm === 'PM') h24 += 12;
        const pad = (n) => String(n).padStart(2, '0');
        return `${y}-${pad(m + 1)}-${pad(d)}T${pad(h24)}:${pad(min)}`;
    };

    // Trigger parent onChange whenever selections update
    const updateSelection = (y, m, d, h12, min, ampm) => {
        const dtStr = computeDateTimeString(y, m, d, h12, min, ampm);
        if (onChange) onChange(dtStr);
    };

    // Calendar navigation
    const handlePrevMonth = () => {
        if (viewMonth === 0) {
            setViewMonth(11);
            setViewYear(prev => prev - 1);
        } else {
            setViewMonth(prev => prev - 1);
        }
    };

    const handleNextMonth = () => {
        if (viewMonth === 11) {
            setViewMonth(0);
            setViewYear(prev => prev + 1);
        } else {
            setViewMonth(prev => prev + 1);
        }
    };

    const handleSelectDay = (day) => {
        setSelectedDate(day);
        updateSelection(viewYear, viewMonth, day, selectedHour, selectedMinute, selectedAmPm);
    };

    const handleSelectHour = (h) => {
        setSelectedHour(h);
        updateSelection(viewYear, viewMonth, selectedDate, h, selectedMinute, selectedAmPm);
    };

    const handleSelectMinute = (m) => {
        setSelectedMinute(m);
        updateSelection(viewYear, viewMonth, selectedDate, selectedHour, m, selectedAmPm);
    };

    const handleSelectAmPm = (ampm) => {
        setSelectedAmPm(ampm);
        updateSelection(viewYear, viewMonth, selectedDate, selectedHour, selectedMinute, ampm);
    };

    const handleToday = () => {
        const now = new Date();
        setViewYear(now.getFullYear());
        setViewMonth(now.getMonth());
        setSelectedDate(now.getDate());
        updateSelection(now.getFullYear(), now.getMonth(), now.getDate(), selectedHour, selectedMinute, selectedAmPm);
    };

    const handleOk = () => {
        const dtStr = computeDateTimeString(viewYear, viewMonth, selectedDate, selectedHour, selectedMinute, selectedAmPm);
        if (onConfirm) onConfirm(dtStr);
    };

    // Calculate calendar days
    const daysInMonth = new Date(viewYear, viewMonth + 1, 0).getDate();
    const firstDayOfWeek = new Date(viewYear, viewMonth, 1).getDay(); // 0 = Sunday
    const daysInPrevMonth = new Date(viewYear, viewMonth, 0).getDate();

    const today = new Date();
    const isCurrentMonthView = today.getFullYear() === viewYear && today.getMonth() === viewMonth;
    const todayDate = today.getDate();

    // Generate days array
    const calendarCells = [];
    // Previous month filler days
    for (let i = firstDayOfWeek - 1; i >= 0; i--) {
        calendarCells.push({
            day: daysInPrevMonth - i,
            isCurrentMonth: false,
            isPrev: true
        });
    }
    // Current month days
    for (let d = 1; d <= daysInMonth; d++) {
        // Disable days in the past (before today)
        const isPast = isCurrentMonthView && d < todayDate;
        calendarCells.push({
            day: d,
            isCurrentMonth: true,
            isToday: isCurrentMonthView && d === todayDate,
            isSelected: d === selectedDate,
            isPast: isPast
        });
    }
    // Next month filler days (fill up to multiple of 7)
    const totalCells = Math.ceil(calendarCells.length / 7) * 7;
    const remaining = totalCells - calendarCells.length;
    for (let i = 1; i <= remaining; i++) {
        calendarCells.push({
            day: i,
            isCurrentMonth: false,
            isNext: true
        });
    }

    // Format human readable preview string
    const formatDisplay = () => {
        const pad = (n) => String(n).padStart(2, '0');
        const mShort = MONTH_NAMES[viewMonth]?.slice(0, 3);
        return `${pad(selectedDate)} ${mShort} ${viewYear}, ${pad(selectedHour)}:${pad(selectedMinute)} ${selectedAmPm}`;
    };

    return (
        <div className="flex flex-col bg-white dark:bg-slate-900 rounded-2xl select-none shadow-xs border border-slate-200 dark:border-slate-800">
            {/* Top Container: Calendar on Left, Time Columns on Right */}
            <div className="flex flex-col sm:flex-row">
                {/* Left: Calendar Section */}
                <div className="p-3 sm:p-4 sm:border-r border-slate-100 dark:border-slate-800 flex-1 min-w-[240px]">
                    {/* Month & Year Header with Controls */}
                    <div className="flex items-center justify-between mb-3 px-1">
                        <div className="flex items-center gap-1">
                            <span className="font-extrabold text-sm text-slate-800 dark:text-slate-100">
                                {MONTH_NAMES[viewMonth]} {viewYear}
                            </span>
                            <span className="material-symbols-outlined text-[16px] text-slate-400">arrow_drop_down</span>
                        </div>
                        <div className="flex items-center gap-1">
                            <button
                                type="button"
                                onClick={handlePrevMonth}
                                className="w-7 h-7 rounded-lg hover:bg-slate-100 dark:hover:bg-slate-800 text-slate-600 dark:text-slate-300 flex items-center justify-center transition-colors cursor-pointer"
                                title="Previous Month"
                            >
                                <span className="material-symbols-outlined text-[16px]">chevron_left</span>
                            </button>
                            <button
                                type="button"
                                onClick={handleNextMonth}
                                className="w-7 h-7 rounded-lg hover:bg-slate-100 dark:hover:bg-slate-800 text-slate-600 dark:text-slate-300 flex items-center justify-center transition-colors cursor-pointer"
                                title="Next Month"
                            >
                                <span className="material-symbols-outlined text-[16px]">chevron_right</span>
                            </button>
                        </div>
                    </div>

                    {/* Weekday Headers */}
                    <div className="grid grid-cols-7 gap-1 text-center mb-1">
                        {DAYS_SHORT.map(dayName => (
                            <span key={dayName} className="text-[11px] font-bold text-slate-400 dark:text-slate-500 py-0.5">
                                {dayName}
                            </span>
                        ))}
                    </div>

                    {/* Days Grid */}
                    <div className="grid grid-cols-7 gap-1 text-center">
                        {calendarCells.map((cell, idx) => {
                            if (!cell.isCurrentMonth) {
                                return (
                                    <span
                                        key={`filler-${idx}`}
                                        className="h-8 flex items-center justify-center text-xs text-slate-300 dark:text-slate-700 pointer-events-none"
                                    >
                                        {cell.day}
                                    </span>
                                );
                            }

                            const isSel = cell.isSelected;
                            const isTod = cell.isToday;
                            const isP = cell.isPast;

                            return (
                                <button
                                    key={`day-${cell.day}`}
                                    type="button"
                                    disabled={isP}
                                    onClick={() => handleSelectDay(cell.day)}
                                    className={`h-8 w-8 mx-auto rounded-lg text-xs font-semibold flex items-center justify-center transition-all cursor-pointer ${
                                        isSel
                                            ? 'bg-slate-900 dark:bg-indigo-600 text-white font-extrabold shadow-sm scale-105 ring-2 ring-slate-900/20 dark:ring-indigo-400/40'
                                            : isP
                                            ? 'text-slate-300 dark:text-slate-600 cursor-not-allowed'
                                            : isTod
                                            ? 'border-2 border-indigo-500 text-indigo-600 dark:text-indigo-400 font-bold hover:bg-indigo-50 dark:hover:bg-indigo-950/40'
                                            : 'text-slate-700 dark:text-slate-200 hover:bg-slate-100 dark:hover:bg-slate-800'
                                    }`}
                                >
                                    {cell.day}
                                </button>
                            );
                        })}
                    </div>
                </div>

                {/* Right: Time Selection Columns (Hours, Minutes, AM/PM) */}
                <div className="p-3 sm:p-4 flex flex-col justify-between bg-slate-50/60 dark:bg-slate-900/60 border-t sm:border-t-0 sm:border-l border-slate-100 dark:border-slate-800">
                    {/* Active Time Header Indicator Boxes (Exact match to Chrome native layout) */}
                    <div className="flex items-center justify-center gap-1.5 mb-2 pb-2 border-b border-slate-200 dark:border-slate-700">
                        <div className="w-12 py-1.5 bg-slate-200 dark:bg-slate-700 text-slate-900 dark:text-white rounded-lg text-center font-mono font-bold text-xs shadow-inner">
                            {String(selectedHour).padStart(2, '0')}
                        </div>
                        <div className="w-12 py-1.5 bg-slate-200 dark:bg-slate-700 text-slate-900 dark:text-white rounded-lg text-center font-mono font-bold text-xs shadow-inner">
                            {String(selectedMinute).padStart(2, '0')}
                        </div>
                        <div className="w-12 py-1.5 bg-slate-200 dark:bg-slate-700 text-slate-900 dark:text-white rounded-lg text-center font-mono font-bold text-xs shadow-inner">
                            {selectedAmPm}
                        </div>
                    </div>

                    {/* Columns */}
                    <div className="flex gap-1.5 justify-center flex-1">
                        {/* Hours Column (01 to 12) */}
                        <div className="flex flex-col items-center">
                            <span className="text-[10px] font-extrabold text-slate-400 uppercase tracking-wider mb-1">
                                Hour
                            </span>
                            <div
                                ref={hoursColRef}
                                className="h-44 w-12 overflow-y-auto custom-scrollbar flex flex-col gap-1 p-0.5"
                            >
                                {[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12].map(h => {
                                    const isSel = selectedHour === h;
                                    return (
                                        <button
                                            key={`hour-${h}`}
                                            type="button"
                                            data-selected={isSel}
                                            onClick={() => handleSelectHour(h)}
                                            className={`w-full py-1.5 rounded-lg text-xs font-bold transition-colors cursor-pointer text-center ${
                                                isSel
                                                    ? 'bg-indigo-600 text-white shadow-xs'
                                                    : 'text-slate-600 dark:text-slate-300 hover:bg-slate-200 dark:hover:bg-slate-800'
                                            }`}
                                        >
                                            {String(h).padStart(2, '0')}
                                        </button>
                                    );
                                })}
                            </div>
                        </div>

                        {/* Minutes Column (00 to 59) */}
                        <div className="flex flex-col items-center">
                            <span className="text-[10px] font-extrabold text-slate-400 uppercase tracking-wider mb-1">
                                Min
                            </span>
                            <div
                                ref={minsColRef}
                                className="h-44 w-12 overflow-y-auto custom-scrollbar flex flex-col gap-1 p-0.5"
                            >
                                {Array.from({ length: 60 }, (_, i) => i).map(m => {
                                    const isSel = selectedMinute === m;
                                    return (
                                        <button
                                            key={`min-${m}`}
                                            type="button"
                                            data-selected={isSel}
                                            onClick={() => handleSelectMinute(m)}
                                            className={`w-full py-1.5 rounded-lg text-xs font-bold transition-colors cursor-pointer text-center ${
                                                isSel
                                                    ? 'bg-indigo-600 text-white shadow-xs'
                                                    : 'text-slate-600 dark:text-slate-300 hover:bg-slate-200 dark:hover:bg-slate-800'
                                            }`}
                                        >
                                            {String(m).padStart(2, '0')}
                                        </button>
                                    );
                                })}
                            </div>
                        </div>

                        {/* AM / PM Column */}
                        <div className="flex flex-col items-center">
                            <span className="text-[10px] font-extrabold text-slate-400 uppercase tracking-wider mb-1">
                                Period
                            </span>
                            <div className="h-44 w-12 flex flex-col gap-1.5 justify-start p-0.5">
                                {['AM', 'PM'].map(period => {
                                    const isSel = selectedAmPm === period;
                                    return (
                                        <button
                                            key={period}
                                            type="button"
                                            onClick={() => handleSelectAmPm(period)}
                                            className={`w-full py-2 rounded-lg text-xs font-extrabold transition-colors cursor-pointer text-center ${
                                                isSel
                                                    ? 'bg-indigo-600 text-white shadow-xs'
                                                    : 'text-slate-600 dark:text-slate-300 hover:bg-slate-200 dark:hover:bg-slate-800'
                                            }`}
                                        >
                                            {period}
                                        </button>
                                    );
                                })}
                            </div>
                        </div>
                    </div>
                </div>
            </div>

            {/* Bottom Bar: Clear, Today on Left; Preview in Middle; OK & Cancel on Right */}
            <div className="px-4 py-3 bg-slate-50 dark:bg-slate-900/90 border-t border-slate-100 dark:border-slate-800 rounded-b-2xl flex items-center justify-between gap-2">
                <div className="flex items-center gap-4">
                    <button
                        type="button"
                        onClick={onClear}
                        className="text-xs font-bold text-blue-600 hover:text-blue-700 dark:text-blue-400 hover:underline transition-colors cursor-pointer"
                    >
                        Clear
                    </button>
                    <button
                        type="button"
                        onClick={handleToday}
                        className="text-xs font-bold text-blue-600 hover:text-blue-700 dark:text-blue-400 hover:underline transition-colors cursor-pointer"
                    >
                        Today
                    </button>
                </div>

                <div className="hidden sm:flex items-center px-2.5 py-1 rounded-lg bg-indigo-50 dark:bg-indigo-950/60 border border-indigo-100 dark:border-indigo-800/40">
                    <span className="text-[11px] font-mono font-bold text-indigo-700 dark:text-indigo-300">
                        {formatDisplay()}
                    </span>
                </div>

                <div className="flex items-center gap-2">
                    {onCancel && (
                        <button
                            type="button"
                            onClick={onCancel}
                            className="px-3 py-1.5 rounded-xl text-xs font-semibold text-slate-500 hover:bg-slate-200 dark:hover:bg-slate-800 transition-colors cursor-pointer"
                        >
                            Cancel
                        </button>
                    )}
                    <button
                        type="button"
                        onClick={handleOk}
                        className="px-5 py-1.5 bg-indigo-600 hover:bg-indigo-700 active:scale-95 text-white font-extrabold text-xs rounded-xl shadow-md hover:shadow-indigo-500/25 flex items-center gap-1.5 cursor-pointer transition-all"
                    >
                        <span className="material-symbols-outlined text-[16px]">check_circle</span>
                        OK
                    </button>
                </div>
            </div>
        </div>
    );
}
