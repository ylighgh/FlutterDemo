#!/usr/bin/env python3
# -*- coding:utf-8 -*-
import socket
from happy_python import *


def insert_value(value: str) -> bool:
    """
    向表中插入数据
    :param value: 插入的数据
    """
    return get_exit_status_of_cmd(
        f"mysql -uroot -pwl991224 -haliyun -e 'use hotel;insert into app (app_nums) values({value});'")


def create_server():
    """
    建立连接
    """
    HOST = '192.168.2.161'
    PORT = 8080
    s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    s.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
    s.bind((HOST, PORT))
    s.listen(5)
    print(f'服务器地址:{HOST}  端口号:{PORT}')
    return s


def connect_client(s):
    """
    传输数据
    """
    while True:
        conn, addr = s.accept()
        print('Connected by', addr)
        recv_data_dic = str_to_dict(conn.recv(4096).decode('utf-8'))
        app_nums = recv_data_dic['appNums']
        if insert_value(app_nums):
            conn.send(dict_to_pretty_json({"code": "200"}).encode('utf-8'))
        else:
            conn.send(dict_to_pretty_json({"code": "500"}).encode('utf-8'))
        conn.close()


def close_server(s):
    """
    断开连接
    """
    s.close()


def main():
    s = create_server()
    connect_client(s)
    close_server(s)


if __name__ == '__main__':
    main()
