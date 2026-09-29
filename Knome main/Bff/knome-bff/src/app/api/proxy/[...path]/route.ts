import { NextRequest, NextResponse } from "next/server";

const GATEWAY_URL = (process.env.GATEWAY_URL || "http://localhost:5000").replace(/\/+$/, "");

async function proxyRequest(req: NextRequest, params: { path: string[] }) {
  try {
    const pathStr = params.path ? params.path.join("/") : "";
    const targetUrl = `${GATEWAY_URL}/api/${pathStr}${req.nextUrl.search}`;

    const token = req.cookies.get("knome_token")?.value;

    const headers = new Headers();
    req.headers.forEach((val, key) => {
      if (key.toLowerCase() !== "host" && key.toLowerCase() !== "cookie") {
        headers.set(key, val);
      }
    });

    if (token) {
      headers.set("Authorization", `Bearer ${token}`);
    }

    let body: any = null;
    if (req.method !== "GET" && req.method !== "HEAD") {
      body = await req.arrayBuffer();
    }

    const gatewayRes = await fetch(targetUrl, {
      method: req.method,
      headers: headers,
      body: body,
      // @ts-ignore
      duplex: "half",
    });

    const resData = await gatewayRes.arrayBuffer();

    const responseHeaders = new Headers();
    gatewayRes.headers.forEach((val, key) => {
      responseHeaders.set(key, val);
    });

    return new NextResponse(resData, {
      status: gatewayRes.status,
      statusText: gatewayRes.statusText,
      headers: responseHeaders,
    });
  } catch (err: any) {
    return NextResponse.json(
      { success: false, message: "BFF Gateway Proxy Error", error: err.message },
      { status: 502 }
    );
  }
}

export async function GET(req: NextRequest, { params }: { params: { path: string[] } }) {
  return proxyRequest(req, params);
}

export async function POST(req: NextRequest, { params }: { params: { path: string[] } }) {
  return proxyRequest(req, params);
}

export async function PUT(req: NextRequest, { params }: { params: { path: string[] } }) {
  return proxyRequest(req, params);
}

export async function PATCH(req: NextRequest, { params }: { params: { path: string[] } }) {
  return proxyRequest(req, params);
}

export async function DELETE(req: NextRequest, { params }: { params: { path: string[] } }) {
  return proxyRequest(req, params);
}
