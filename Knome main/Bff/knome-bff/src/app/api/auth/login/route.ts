import { NextRequest, NextResponse } from "next/server";

const GATEWAY_URL = (process.env.GATEWAY_URL || "http://localhost:5000").replace(/\/+$/, "");

export async function POST(req: NextRequest) {
  try {
    let body: any;
    try {
      body = await req.json();
    } catch {
      return NextResponse.json(
        { success: false, message: "Invalid or empty JSON request body" },
        { status: 400 }
      );
    }

    const response = await fetch(`${GATEWAY_URL}/api/v1/auth/login`, {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
      },
      body: JSON.stringify(body),
    });

    const contentType = response.headers.get("content-type");
    const isJson = contentType && contentType.includes("application/json");
    const data = isJson ? await response.json() : null;

    if (!response.ok) {
      return NextResponse.json(
        data || {
          success: false,
          message: `Upstream service error (${response.statusText || response.status})`,
        },
        { status: response.status }
      );
    }

    const rawData = data?.data || data || {};
    const token = rawData.token || data?.token;

    if (!token) {
      return NextResponse.json(
        { success: false, message: "Authentication succeeded but no token received from backend" },
        { status: 502 }
      );
    }

    // Sanitize payload: strip the raw token from JSON response to prevent XSS theft
    const { token: _jwt, ...safeData } = rawData;

    const res = NextResponse.json(
      {
        success: true,
        data: safeData,
        message: "Login successful (BFF Token secured)",
      },
      { status: 200 }
    );

    // Store JWT in secure HTTP-Only cookie to prevent XSS theft
    res.cookies.set({
      name: "knome_token",
      value: token,
      httpOnly: true,
      secure: process.env.NODE_ENV === "production",
      sameSite: "lax",
      path: "/",
      maxAge: 60 * 60 * 24 * 7, // 7 days
    });

    return res;
  } catch (error: any) {
    return NextResponse.json(
      { success: false, message: error.message || "BFF Login Service Error" },
      { status: 500 }
    );
  }
}

