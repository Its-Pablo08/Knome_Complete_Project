import { NextResponse } from "next/server";

export async function POST() {
  const res = NextResponse.json({
    success: true,
    message: "Logged out successfully",
  });

  // Clear HTTP-Only authentication cookie
  res.cookies.set({
    name: "knome_token",
    value: "",
    httpOnly: true,
    expires: new Date(0),
    path: "/",
  });

  return res;
}
