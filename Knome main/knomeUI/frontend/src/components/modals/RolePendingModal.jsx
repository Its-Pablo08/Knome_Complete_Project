import React, { useState, useEffect } from 'react';
import { useUser } from '../contexts/UserContext';

export default function RolePendingModal() {
    const { currentUser, logout } = useUser();
    const [isOpen, setIsOpen] = useState(false);
    const [isDismissed, setIsDismissed] = useState(false);

    const isRolePending = currentUser && (
        currentUser.role === 'PENDING' ||
        currentUser.roleName === 'Pending Role Assignment' ||
        (Array.isArray(currentUser.roles) && currentUser.roles.length === 0) ||
        (Array.isArray(currentUser.roles) && currentUser.roles.length === 1 && currentUser.roles[0] === 'Pending Role Assignment')
    );

    useEffect(() => {
        if (isRolePending && !isDismissed) {
            setIsOpen(true);
        } else {
            setIsOpen(false);
        }
    }, [isRolePending, isDismissed]);

    if (!isOpen || !isRolePending) return null;

    const handleDismiss = () => {
        setIsDismissed(true);
        setIsOpen(false);
    };

    const handleLogout = () => {
        logout();
    };

    return (
        <div className="fixed inset-0 z-[200] flex items-center justify-center p-4 bg-slate-950/80 backdrop-blur-md animate-in fade-in duration-300">
            {/* Main Modal Card */}
            <div className="relative w-full max-w-lg bg-slate-900/95 border border-amber-500/40 rounded-3xl p-8 shadow-2xl shadow-amber-500/10 text-center overflow-hidden animate-in zoom-in-95 duration-300">
                
                {/* Background Amber Glow */}
                <div className="absolute top-[-20%] left-[50%] translate-x-[-50%] w-72 h-72 rounded-full bg-amber-500/15 blur-3xl pointer-events-none"></div>

                {/* Animated Pending Icon Badge */}
                <div className="relative mx-auto mb-6 w-20 h-20 rounded-2xl bg-gradient-to-tr from-amber-500/20 via-amber-400/10 to-orange-500/20 border border-amber-400/40 flex items-center justify-center shadow-lg shadow-amber-500/20">
                    <span className="material-symbols-outlined text-amber-400 text-4xl animate-pulse">
                        hourglass_top
                    </span>
                    <span className="absolute -top-1 -right-1 flex h-4 w-4">
                        <span className="animate-ping absolute inline-flex h-full w-full rounded-full bg-amber-400 opacity-75"></span>
                        <span className="relative inline-flex rounded-full h-4 w-4 bg-amber-500"></span>
                    </span>
                </div>

                {/* Header Titles */}
                <div className="space-y-1 mb-6">
                    <div className="inline-block px-3 py-1 rounded-full bg-amber-500/15 border border-amber-500/30 text-amber-400 text-xs font-black uppercase tracking-wider mb-2">
                        ⏳ Role Assignment Pending
                    </div>
                    <h2 className="text-2xl font-black text-white tracking-tight">
                        Welcome, {currentUser?.name || currentUser?.fullName || 'Team Member'}! 👋
                    </h2>
                    <p className="text-xs text-slate-400 font-medium">
                        Your account has been connected via EmployeeHub SSO
                    </p>
                </div>

                {/* Information Callout Box */}
                <div className="bg-slate-800/80 border border-slate-700/60 rounded-2xl p-4 mb-6 text-left space-y-3 shadow-inner">
                    <div className="flex items-start gap-3">
                        <span className="material-symbols-outlined text-amber-400 text-xl mt-0.5 shrink-0">
                            mark_chat_read
                        </span>
                        <div className="text-xs text-slate-300 leading-relaxed">
                            <span className="font-bold text-amber-300">Role request submitted:</span> A notification regarding your role request status has been routed for <span className="text-white font-mono font-bold bg-slate-700/60 px-1.5 py-0.5 rounded">{currentUser?.name || currentUser?.fullName || 'your account'}</span>.
                        </div>
                    </div>

                    {/* Employee Profile Preview Grid */}
                    <div className="pt-2 border-t border-slate-700/60 grid grid-cols-2 gap-2 text-xs">
                        <div className="bg-slate-900/60 p-2.5 rounded-xl border border-slate-700/40">
                            <span className="text-[11px] text-slate-400 font-semibold block">Employee Name</span>
                            <span className="text-white font-bold truncate block">{currentUser?.name || currentUser?.fullName || 'Employee'}</span>
                        </div>
                        <div className="bg-slate-900/60 p-2.5 rounded-xl border border-slate-700/40">
                            <span className="text-[11px] text-slate-400 font-semibold block">Department</span>
                            <span className="text-white font-bold truncate block">{currentUser?.department || 'General'}</span>
                        </div>
                        <div className="bg-slate-900/60 p-2.5 rounded-xl border border-slate-700/40 col-span-2 flex items-center justify-between">
                            <span className="text-[11px] text-slate-400 font-semibold">Designation</span>
                            <span className="text-slate-200 font-medium">{currentUser?.designation || 'Staff'}</span>
                        </div>
                    </div>
                </div>

                {/* System Admin Notice */}
                <p className="text-xs text-slate-400 leading-relaxed mb-6">
                    The <strong className="text-amber-300">System Admin</strong> has been notified to assign your access role. Once approved, you will receive full permissions and an in-app notification alert.
                </p>

                {/* Action Buttons */}
                <div className="flex flex-col sm:flex-row gap-3">
                    <button
                        onClick={handleDismiss}
                        className="flex-1 py-3 px-4 rounded-xl bg-gradient-to-r from-amber-500 to-orange-500 hover:from-amber-400 hover:to-orange-400 text-slate-950 font-black text-xs transition-all shadow-lg shadow-amber-500/25 flex items-center justify-center gap-2 cursor-pointer"
                    >
                        <span>Continue to Portal</span>
                        <span className="material-symbols-outlined text-sm">arrow_forward</span>
                    </button>
                    <button
                        onClick={handleLogout}
                        className="py-3 px-4 rounded-xl bg-slate-800 hover:bg-slate-700 text-slate-300 hover:text-white font-bold text-xs transition-all border border-slate-700/80 flex items-center justify-center gap-1.5 cursor-pointer"
                    >
                        <span className="material-symbols-outlined text-sm">logout</span>
                        <span>Sign Out</span>
                    </button>
                </div>
            </div>
        </div>
    );
}
